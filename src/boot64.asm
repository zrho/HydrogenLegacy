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
; Bootstrap (Long Mode) - BSP
;-------------------------------------------------------------------------------

; 64 bit entry point for the BSP.
boot64_bsp:
	; Prepare
	cli										; Clear interrupts
	and rsp, ~0xFFF							; Reset stack
	mov ax, 0x10							; Load data segment selector
	mov ds, ax

	; Welcome message
	call screen_clear
	mov rsi, message_header
	call screen_write

	; Initialize the system
	call multiboot_parse					; Parse multiboot tables
	call acpi_parse							; Parse ACPI tables

	call modules_sort						; Sort the modules (for moving)
	call modules_move						; Move modules to new location

	call int_init							; Initialize IDT
	call int_load							; Load IDT
	call lapic_enable						; Enable the LAPIC
	call pic_init							; Initializes the 8259 PIC
	call smp_init							; Initialize SMP

	; Initialize the kernel
	call kernel_find						; Search for the kernel
	call kernel_map							; Map the kernel

	; Jump to the kernel
	mov rsi, message_kernel
	call screen_write

	mov rax, HYDROGEN_KERNEL_ENTRY_VADDR
	jmp rax

boot64_ap:
	; Prepare
	cli										; Clear interrupts
	and rsp, ~0xFFF							; Reset stack

	; Initialize
	call int_load							; Load IDT
	call lapic_enable						; Enable the LAPIC
	call smp_init_ap						; Initialize SMP from AP side

	; Halt loop
	sti
.halt:
	hlt
	jmp .halt
