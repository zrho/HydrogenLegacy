; Hydrogen Operating System
; Copyright (C) 2011 Lukas Heidemann
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

section .text
bits 64

;-------------------------------------------------------------------------------
; Interrupts - I/O APIC
;-------------------------------------------------------------------------------

; Initializes all I/O APICs.
ioapic_init_all:
	; Store
	push rcx
	push rsi
	push rdi

	; Check if the system has at least one I/O APIC
	mov cl, byte [info_table.ioapic_count]
	cmp rcx, 0
	je .end

	; Iterate though I/O APICs
	mov rdi, info_ioapic

.handle:
	; Get address of I/O APIC
	mov esi, dword [rsi + hydrogen_info_ioapic.address]

	; Inspect and mask all redirections
	call ioapic_inspect
	call ioapic_mask_all

.next:
	; Next?
	dec rcx
	add rdi, hydrogen_info_ioapic.end
	cmp rcx, 0
	jne .handle

.end:
	; Restore
	pop rdi
	pop rsi
	pop rcx
	ret

; Masks all redirections for a given I/O APIC.
;
; Parameters:
;	rsi The address of the I/O APIC.
;	rdi The address of the I/O APIC's entry in the info table.
ioapic_mask_all:
	; Store
	push rax
	push rcx

	; Mask all redirections
	mov cl, byte [rdi + hydrogen_info_ioapic.int_count]

.mask:
	call ioapic_entry_read
	or rax, IOAPIC_REDIR_MASK
	call ioapic_entry_write

.mask_next:
	dec rcx
	cmp rcx, 0
	jne .mask

	; Restore
	pop rcx
	pop rax
	ret

; Inspects an I/O further to extract more information than it could be found
; in the ACPI tables.
;
; Extracts the number of interrupts handled by this I/O APIC.
;
; Parameters:
;	rsi The address of the I/O APIC.
;	rdi The address of the I/O APIC's entry in the info table.
ioapic_inspect:
	; Store
	push rax
	push rcx

	; Extract max redirection and add one for int count
	mov rcx, IOAPIC_IOAPICVER_INDEX		; Read IOAPICVER register
	call ioapic_reg_read
	shr rax, 23							; Extract bytes 23-26
	and rax, 1111b
	add rax, 1							; Add one to get interrupt count
	mov byte [rdi + hydrogen_info_ioapic.int_count], al

	; Restore
	pop rcx
	pop rax
	ret

; Writes to an (internal) I/O APIC register.
;
; Parameters:
;	eax The value to write.
; 	ecx	The index of the register
;	rsi The I/O APIC's base address.
ioapic_reg_write:
	mov dword [rsi + ioapic.regsel], ecx	; Write register selector
	mov dword [rsi + ioapic.iowin], eax		; Write value
	ret

; Reads an (internal) I/O APIC register.
;
; Parameters:
;	ecx The index of the register.
;	rsi The I/O APIC's base address.
;
; Returns:
;	eax The value of the register.
ioapic_reg_read:
	mov dword [rsi + ioapic.regsel], ecx	; Write register selector
	mov eax, dword [rsi + ioapic.iowin]
	ret

; Writes an entry in an I/O APIC's redirection table.
;
; Parameters:
;	rax The entry to write.
;	ecx The index of the entry.
;	rsi The I/O APIC's base address.
ioapic_entry_write:
	; Store
	push rax
	push rcx

	; Calculate index for lower DWORD
	shl rcx, 1							; * 2: 2 registers for each entry
	add rcx, IOAPIC_IOREDTBL_OFFSET		; Add offset

	; Write lower DWORD
	call ioapic_reg_write

	; Write higher DWORD
	shr rax, 32
	add rcx, 1							; Next register for high DWORD
	call ioapic_reg_write

	; Restore
	pop rcx
	pop rax
	ret

; Reads an entry in an I/O APIC's redirection table.
;
; Parameters:
;	ecx The index of the entry.
;	rsi The I/O APIC's base address.
;
; Returns:
; 	rax The entry value.
ioapic_entry_read:
	; Store
	push rbx
	push rcx

	; Calculate index for lower DWORD
	shr rcx, 1
	add rcx, IOAPIC_IOREDTBL_OFFSET

	; Read lower DWORD
	call ioapic_reg_read
	mov rbx, rax			; Backup lower DWORD

	; Read higher DWORD
	add rcx, 1
	call ioapic_reg_read

	; Combine
	shr rax, 32
	or rbx, rax
	xchg rbx, rax

	; Restore
	pop rcx
	pop rbx
	ret
