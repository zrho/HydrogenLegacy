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

info_ioapic_next: dq info_ioapic
info_string_next: dq info_strings

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
; Kernel
;-------------------------------------------------------------------------------

; The address of the descriptor of the module that hosts the kernel
kernel_module: dq 0x0

; The address of the kernel entry point
kernel_entry: dq 0x0

; The address of the string table in the kernel binary
kernel_string_table: dq 0x0

; Name of the symbol of the config table
kernel_symbol_config: dq "hydrogen_config", 0

;-------------------------------------------------------------------------------
; Messages
;-------------------------------------------------------------------------------

message_header:
	db "Hydrogen v0.1b - http://github.com/farok/Hydrogen", CHAR_NL
	db "Copyright (c) 2011 by Lukas Heidemann", CHAR_NL
	db "-------------------------------------------------", CHAR_NL
	db "Initializing the system...", CHAR_NL, 0

message_ap_started:
	db "Application Processor started.", CHAR_NL, 0

message_no_kernel:
	db "PANIC: No kernel binary could be found. Make sure to pass "
	db "the kernel as a module with cmdline beginning with 'kernel64'.", 0

message_kernel_broken:
	db "PANIC: Kernel binary is no executable, little-endian ELF64 file.", 0

message_kernel:
	db "Starting kernel...", 0

;-------------------------------------------------------------------------------
; Misc
;-------------------------------------------------------------------------------

; Number of ticks of the PIT
ticks: dq 0x0

; The IRQ number to use for the PIT
pit_irq: db 0x0

; Cursor positions for the screen
screen:
	.cursor_x: dw 0x0
	.cursor_y: dw 0x0
