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

;-------------------------------------------------------------------------------
; Utility - Instruction Sequences
;-------------------------------------------------------------------------------

; Exchanges two values in memory (not thread safe).
;
; Parameters:
;	%1 Address or register with address for the first value.
;	%2 Address of register with address for the second value.
;	%3 Size of the value (byte/word/dword/qword)
;
; Example:
;	xchg_mem 0x1000, rsi, qword
%macro xchg_mem	3
	push rax
	push %3 [%1]
	mov rax, %3 [%2]
	mov %3 [%1], rax
	pop %3 [%2]
	pop rax
%endmacro

; Aligns a register to a 4kB page boundary.
;
; Parameters:
;	%1 Name of the register to align
;
; Example:
; 	align_page rdi
%macro align_page 1
	add %1, 0xFFF			; Add 0x1000-1, for all but for aligned addresses
							; this will advance in the next page
	and %1, ~0xFFF			; Now clear the lower 12 bits
%endmacro
