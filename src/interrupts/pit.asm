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
; Interrupts - PIT
;-------------------------------------------------------------------------------

; Initializes the PIT.
pit_init:
	; Store
	push rax
	push rcx
	push rsi
	push rdi

	; Sets the PIT's frequency to PIT_FREQ
	mov rax, PIT_FREQ
	call pit_freq_set

	; Set the IDT entry for the PIT to IRQ0
	mov rcx, IRQ_VECTOR
	mov rdx, pit_tick
	call int_write_entry

	; Check if 8259 PIC is supported
	mov rax, info_table.flags
	mov al, byte [rax]
	and rax, INFO_FLAG_PIC
	cmp rax, 0
	je .no_pic

	; Found PIC, so assume that IRQ0 is mapped to
	; IRQ2 in the I/O APIC, so adjust the entry:
	; Get GSI number for IRQ2
	mov rax, info_table.irq_to_gsi
	add rax, (2 * 4)
	mov ecx, dword [rax]

	; Get entry for GSI
	call ioapic_entry_get
	call ioapic_entry_read

	; Map entry to PIT's IRQ vector
	and rax, ~IOAPIC_REDIR_VECTOR_MASK
	or rax, IRQ_VECTOR
	call ioapic_entry_write

	; Store new IRQ number
	mov byte [pit_irq], 2

.no_pic:

	; Restore
	pop rdi
	pop rsi
	pop rcx
	pop rax
	ret

; Sets the PIT's frequency.
;
; Parameters:
; 	rax The new frequency in Hz.
pit_freq_set:
	; Store
	push rax
	push rbx
	push rdx

	; Calculate divider in rbx
	mov rbx, rax
	mov rax, PIT_FREQ_BASE
	div ebx
	mov rbx, rax

	; Send command byte
	mov dx, PIT_IO_COMMAND
	mov al, PIT_IO_COMMAND_DIVIDER
	out dx, al

	; Send lower byte
	mov rax, rbx
	mov dx, PIT_IO_DATA
	out dx, al

	; Send higher byte
	shr rax, 8
	out dx, al

	; Restore
	pop rdx
	pop rbx
	pop rax
	ret

pit_enable:
	; Store
	push rcx

	; Unmask IRQ
	mov cl, byte [pit_irq]
	call irq_unmask

	; Restore
	pop rcx
	ret

pit_disable:
	; Store
	push rcx

	; Mask IRQ
	mov cl, byte [pit_irq]
	call irq_mask

	; Restore
	pop rcx
	ret

pit_tick:
	inc qword [ticks]
	call lapic_eoi

	iretq
