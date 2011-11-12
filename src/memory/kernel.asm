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

section .data
bits 64

; Searches for the kernel binary in the list of loaded modules.
kernel_find:
	; Store
	push rax
	push rbx
	push rcx
	push rdx
	push rsi

	; No modules?
	xor rcx, rcx
	mov cl, byte [info_table.mod_count]
	cmp cl, 0
	je .not_found

	; Iterate over list
	mov rsi, info_mods

.parse:
	; Cmdline is null-pointer?
	mov rdx, qword [rsi + hydrogen_info_mod.cmdline]
	cmp rdx, 0
	je .next

	; Cmdline begins with kernel module name
	mov rbx, "kernel64"
	mov rax, qword [rdx]
	cmp rbx, rax
	jne .next

	; Found kernel module
	mov qword [kernel_module], rsi
	jmp .found

.next:
	; Check for next
	add rsi, 24				; Add module descriptor size
	dec rcx					; Decrease remaining module count
	cmp rcx, 0
	jne .parse

	; Fall through
.not_found:
	; Panic
	mov rsi, message_no_kernel
	call screen_write
	jmp $

.found:
	; Restore
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret

; Checks and loads the kernel binary.
kernel_load:
	; Store
	push rax
	push rsi

	; Get the address of the kernel binary
	mov rsi, kernel_module
	mov rsi, qword [rsi]
	mov rsi, qword [rsi + hydrogen_info_mod.begin]

	; Check the binary
	call elf64_check
	cmp rax, 0
	je .broken

	; Load the binary
	call elf64_load

	; Get the kernel entry point
	mov rax, qword [rsi + elf64_ehdr.e_entry]
	mov qword [kernel_entry], rax

	; Restore
	pop rsi
	pop rax
	ret

.broken:
	; Panic
	mov rsi, message_kernel_broken
	call screen_write
	jmp $
