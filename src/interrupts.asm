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
; Interrupts - IDT
;-------------------------------------------------------------------------------

; Clears the interrupt descriptor table.
int_init:
	; Store
	push rax
	push rcx
	push rdi

	; Clear IDT
	mov rdi, sys_idt64					; Load idt address
	mov rcx, 512						; 4kB = 512 * 8 byte
	xor rax, rax						; Fill with zeroes
	rep stosq

	; Restore
	pop rdi
	pop rcx
	pop rax
	ret

; Loads the IDT into the CPU's registers
int_load:
	lidt [sys_idtr64]
	ret
