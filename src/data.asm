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

;-------------------------------------------------------------------------------
; Bootstrap Data
;-------------------------------------------------------------------------------

; The address of the next protected mode stack
boot32_stack_next: dd stack_heap

; Whether the current CPU is the BSP; flag cleared by the BSP.
boot32_bsp: db 0x1

; 32 bit physical address of the multiboot info table.
boot32_mboot: dd 0x0

;-------------------------------------------------------------------------------
; Info Table
;-------------------------------------------------------------------------------

; The info table to be passed to the kernel.
info_table:
	.free_mem_begin:	dq 0x0
	.command_line:		dq 0x0
	.lapic_paddr:		dq 0x0
	.idtr_paddr:		dq sys_idtr64
	.gdtr_paddr:		dq sys_gdtr64
	.flags:				db 0x0
	.proc_count:		db 0x0
	.mod_count:			db 0x0
	.mmap_count:		db 0x0

info_proc_next:	dq info_proc

;-------------------------------------------------------------------------------
; System Tables and their pointers
;-------------------------------------------------------------------------------

; The pointer to the system's IDT.
sys_idtr64:
.length:
	dw 0xFFF
.pointer:
	dq sys_idt64

; The pointer to the system's 64 bit GDT.
sys_gdtr64:
.length:
	dw 0x27
.pointer:
	dq sys_gdt64

;-------------------------------------------------------------------------------
; Misc
;-------------------------------------------------------------------------------

screen:
	.cursor_x: dw 0x0
	.cursor_y: dw 0x0
