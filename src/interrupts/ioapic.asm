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

	; Inspect and initialize redirections
	call ioapic_inspect
	call ioapic_init_entries

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

; Initializes an I/O APIC's redirections.
;
; Parameters:
;	rsi The address of the I/O APIC.
;	rdi The address of the I/O APIC's entry in the info table.
ioapic_init_entries:
	; Store
	push rax
	push rcx

	; Initialize all entries
	mov cl, byte [rdi + hydrogen_info_ioapic.int_count]

.mask:
	dec rcx
	call ioapic_init_entry

.mask_next:
	cmp rcx, 0
	jne .mask

	; Restore
	pop rcx
	pop rax
	ret

; Initializes a given redirection entry.
;
; Standard Fields:
; 	Vector: 0
; 	Delivery Mode: Fixed
; 	Destination Mode: Physical
; 	Pin Polarity: Low Active
; 	Trigger Mode: Edge
; 	Mask: Masked
; 	Destination: Current processor's (BSP) id
;
; Sets the vector for IRQ entries.
;
; Parameters:
; 	rsi The address of the I/O APIC.
; 	rdi The address of the I/O APIC's entry in the info table.
; 	rcx The index of the redirection entry to initialize.
ioapic_init_entry:
	; Store
	push rax
	push rbx
	push rdx

	; Standard fields
	mov rax,	(LAPIC_DELIVERY_FIXED << IOAPIC_REDIR_DELMOD_OFFSET) | \
	         	(LAPIC_MODE_PHYSICAL << IOAPIC_REDIR_DESTMOD_OFFSET) | \
				(IOAPIC_REDIR_INTPOL_LOW << IOAPIC_REDIR_INTPOL_OFFSET) | \
				(LAPIC_TRIGGER_EDGE << IOAPIC_REDIR_TRIGGER_OFFSET) | \
				(1 << IOAPIC_REDIR_MASK_OFFSET)

	; Get BSP APIC id
	xchg rax, rbx
	call smp_id
	shl rax, IOAPIC_REDIR_DEST_OFFSET
	or rbx, rax
	mov rdx, rbx				; Store entry value in rdx

	; Calculate global system interrupt number (index + int_base)
	mov ebx, dword [rdi + hydrogen_info_ioapic.int_base]
	add rbx, rcx

	; Check if ISA IRQ
	xchg rbx, rcx				; GSI number in rcx
	call ioapic_gsi_to_irq
	xchg rbx, rcx				; Restore

	cmp rax, ~0
	jne .irq

.irq:
	; Set vector (IRQ number + IOAPIC_IRQ_VECTOR)
	add rax, IOAPIC_IRQ_VECTOR
	or rdx, rax

.no_irq:
	; Write entry
	mov rax, rdx
	call ioapic_entry_write

	; Restore
	pop rdx
	pop rbx
	pop rax
	ret

; Checks whether an global system interrupt maps to an ISA IRQ and returns
; the IRQ number, if it does.
;
; Parameters:
;	rcx The number of the global system interrupt to check.
;
; Returns:
;	rax The number of the IRQ, or ~0 if the GSI does not map to an IRQ.
ioapic_gsi_to_irq:
	; Store
	push rbx
	push rsi

	; Check IRQ to GSI mapping, if it contains the GSI
	xor rbx, rbx							; Current IRQ
	mov rsi, info_table.irq_to_gsi			; IRQ to GSI table

.check:
	lodsd			; Load entry
	cmp rax, rcx	; GSI numbers match?
	je .irq

	; Next
	inc rbx
	cmp rbx, 16
	jl .check
	jmp .no_irq

.irq:
	; Return IRQ number
	mov rax, rbx
	jmp .end

.no_irq:
	; Is no IRQ, return ~0
	mov rax, ~0

.end:
	; Restore
	pop rsi
	pop rbx
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
