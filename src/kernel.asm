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

kernel_map:
	; Store
	push rax
	push rcx
	push rsi
	push rdi

	; Clear PDP
	mov rdi, paging_pdp_kernel
	xor rax, rax
	mov rcx, 512
	rep stosq

	; Clear PD
	mov rdi, paging_pd_kernel
	mov rcx, 512
	rep stosq

	; Clear PT
	mov rdi, paging_pt_kernel
	mov rcx, 512
	rep stosq

	; Map PDP in PML4
	mov rax, paging_pdp_kernel
	or rax, PAGE_FLAG_PW; | PAGE_FLAG_GLOBAL
	mov qword [paging_pml4 + 510 * 8], rax

	; Map PD in PDP
	mov rax, paging_pd_kernel
	or rax, PAGE_FLAG_PW; | PAGE_FLAG_GLOBAL
	mov qword [paging_pdp_kernel], rax

	; Map PT in PD
	mov rax, paging_pt_kernel
	or rax, PAGE_FLAG_PW; | PAGE_FLAG_GLOBAL
	mov qword [paging_pd_kernel], rax

	; Get size of kernel binary
	mov rsi, qword [kernel_module]			; Get kernel mod structure
	mov rcx, qword [rsi + hydrogen_info_mod.length] ; Get module length

	; Map pages in PT
	mov rax, qword [rsi + hydrogen_info_mod.begin]
	or rax, PAGE_FLAG_PW; | PAGE_FLAG_GLOBAL
	mov rdi, paging_pt_kernel

	cmp rcx, 0								; Page remaining?
	jle .end
.page_map:
	stosq									; Write entry
	add rax, 0x1000							; Advance by one page
	sub rcx, 0x1000							; Subtract from remaining length
	cmp rcx, 0								; Memory left for mapping?
	jg .page_map

.end:
	mov rsi, MEMORY_KERNEL_ENTRY_VADDR
	mov rax, qword [rsi]

	; Restore
	pop rdi
	pop rsi
	pop rcx
	pop rax
	ret
