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
; Interrupts - LAPIC and IPIs
;-------------------------------------------------------------------------------

; Enables the LAPIC.
lapic_enable:
	; Store
	push rax
	push rsi

	; Load the value of the SVR
	mov rsi, [info_table.lapic_paddr]
	add rsi, LAPIC_SVR_OFFSET
	xor rax, rax
	mov eax, dword [rsi]
	or rax, (1 << 8)
	mov dword [rsi], eax

	; Restore
	pop rsi
	pop rax
	ret

; Sends an IPI using the current processor's LAPIC.
;
; Parameters:
;	r8  Vector
;	r9  Delivery Mode
;   r10 Destination Mode
; 	r11 Level
;	r12 Trigger Mode
; 	r13 Destination Shorthand
; 	r14 Destination Field
lapic_ipi_send:
	; Store
	push rax
	push rbx
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14

	; Shift and mask parameters
	and r8, 0xFF				; Vector (0..7)
	and r9, 111b				; Delivery Mode (8..10)
	shl r9, 8
	and r10, 1					; Destination Mode (11)
	shl r10, 11
	and r11, 1					; Level (14)
	shl r11, 14
	and r12, 1					; Trigger Mode (15)
	shl r12, 15
	and r13, 11b				; Destination Shorthand (18..19)
	shl r13, 18
	and r14, 0xFF				; Destination Field (56..63)
	shl r14, 56

	; Assemble request
	xor rbx, rbx
	or rbx, r8
	or rbx, r9
	or rbx, r10
	or rbx, r11
	or rbx, r12
	or rbx, r13
	or rbx, r14

	; Write higher dword (write to low fires IPI)
	mov rax, rbx
	shr rax, 32
	mov rdi, qword [info_table.lapic_paddr]
	add rdi, LAPIC_ICR_HIGH_OFFSET
	mov dword [rdi], eax

	; Write lower dword
	xor rax, rax
	mov eax, ebx
	mov rdi, qword [info_table.lapic_paddr]
	add rdi, LAPIC_ICR_LOW_OFFSET
	mov dword [rdi], eax

	; Restore
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop rdi
	pop rbx
	pop rax
	ret

; Sends an init IPI to the processor with the apic id stored in rax.
;
; Parameters:
;	rax The apic id of the target processor.
lapic_ipi_init:
	; Store
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14

	; Setup IPI
	mov r8, 0x0						; Vector (entry point address >> 12)
	mov r9,	LAPIC_DELIVERY_INIT		; Delivery Mode
	mov r10, LAPIC_MODE_PHYSICAL	; Destination Mode (Physical)
	mov r11, LAPIC_LEVEL_ASSERT		; Level (Assert)
	mov r12, LAPIC_TRIGGER_EDGE		; Trigger Mode (Edge)
	mov r13, LAPIC_SHORT_NONE		; Destination Shorthand (None)
	mov r14, rax					; Destination Field

	; Send IPI
	call lapic_ipi_send

	; Restore
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	ret

; Sends a startup IPI to the processor with the apic id stored in rax.
;
; Parameters:
;	rax The apic id of the target processor.
lapic_ipi_startup:
	; Store
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14

	; Setup IPI
	mov r8, 0x1						; Vector (entry point address >> 12)
	mov r9,	LAPIC_DELIVERY_STARTUP	; Delivery Mode
	mov r10, LAPIC_MODE_PHYSICAL	; Destination Mode (Physical)
	mov r11, LAPIC_LEVEL_ASSERT		; Level (Assert)
	mov r12, LAPIC_TRIGGER_EDGE		; Trigger Mode (Edge)
	mov r13, LAPIC_SHORT_NONE		; Destination Shorthand (None)
	mov r14, rax					; Destination Field

	; Send IPI
	call lapic_ipi_send

	; Restore
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	ret
