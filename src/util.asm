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
; Strings
;-------------------------------------------------------------------------------

; Returns the length of the string at rsi.
;
; Parameters:
; 	rsi	The address of the string.
;
; Returns:
;	rax The length of the string.
string_length:
	; Store
	push rcx
	push rsi

	; Increment counter until nul-byte is reached
	xor rcx, rcx					; Counter
	xor rax, rax					; Register for current byte

.next:
	lodsb							; Load byte
	cmp rax, 0						; Null byte?
	je .null

	inc rcx							; Increment counter
	jmp .next						; Next character

.null:
	; Restore
	xchg rax, rcx					; Counter in rax
	pop rsi
	pop rcx
	ret

; Copies a string from rsi to rdi.
;
; Parameters:
;	rsi The address of the string to copy.
;	rdi The address to copy the string to.
;
; Returns:
; 	rdi The address after the copied string's null byte.
string_copy:
	; Store
	push rax
	push rsi

	; Copy bytes until nul-byte is reached
	xor rax, rax					; Register for current byte

.next:
	lodsb							; Load
	stosb							; and write

	cmp rax, 0						; Null byte?
	jne .next

.null:
	; Restore
	pop rsi
	pop rax
	ret

; Copies rcx bytes from rsi to rdi.
;
; Parameters:
; 	rsi The address to copy from.
; 	rdi The address to copy to.
; 	rcx The number of bytes to copy.
memory_copy:
	; No bytes to copy?
	cmp rcx, 0
	jne .begin
	ret

.begin:
	; Store
	push rax
	push rcx
	push rsi
	push rdi

.next_byte:
	; Copy byte
	lodsb
	stosb

	; Byte left?
	dec rcx
	cmp rcx, 0
	jne .next_byte

	; Restore
	pop rdi
	pop rsi
	pop rcx
	pop rax
	ret

wait_busy:
	push rcx
	mov rcx, 2000
.next:
	dec rcx
	cmp rcx, 0
	jne .next
	pop rcx
	ret
