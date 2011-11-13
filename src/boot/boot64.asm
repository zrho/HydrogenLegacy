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
	mov ax, 0x10							; Load data segment selectors
	mov ds, ax
	mov gs, ax
	mov fs, ax
	mov ss, ax

	; Welcome message
	call screen_clear
	mov rsi, message_header
	call screen_write

	; Initialize the info tables
	call info_prepare						; Prepare the info structure
	call multiboot_parse					; Parse multiboot tables
	call acpi_parse							; Parse ACPI tables

	call modules_sort						; Sort the modules (for moving)
	call modules_move						; Move modules to new location

	; Load the kernel
	call kernel_find						; Search for the kernel
	call kernel_load						; Load the kernel
	call kernel_inspect						; Inspect the kernel binary

	; Initialize interrupt handling
	call int_init							; Initialize IDT
	call int_load							; Load IDT

	; Initialize interrupt controllers and IRQs
	call lapic_enable						; Enable the LAPIC
	call lapic_timer_lvt_calc				; Calculate the LVT for the timer
	call pic_init							; Initialize the 8259 PIC
	call ioapic_init						; Initialize all I/O APICs
	call irq_wire							; Wire IRQs

	; Initialize the PIT
	call pit_init							; Initialize the PIT
	call pit_enable							; Enable the PIT

	; Initialization with interrupts enabled
	sti										; Enable interrupts
	call lapic_timer_calibrate				; Calibrate the LAPIC timer
	call smp_init							; Initialize SMP
	cli										; Disable interrupts

	; Prepare IRQs for kernel
	call pit_disable						; Disable the PIT again (not used anymore)
	call irq_set_masks						; Set IRQ masks

	; Jump to the kernel
	mov rsi, message_kernel
	call screen_write
	mov byte [entry_barrier], 1				; Open barrier

	mov rax, kernel_entry
	mov rax, qword [rax]
	jmp rax

; 64 bit entry point for APs.
boot64_ap:
	; Prepare
	cli										; Clear interrupts
	and rsp, ~0xFFF							; Reset stack

	; Initialize
	call int_load							; Load IDT
	call lapic_enable						; Enable the LAPIC
	call pit_redirect						; Redirect the PIT to this processor

	; Initialization with interrupts
	sti
	call lapic_timer_calibrate				; Calibrate the LAPIC timer
	cli

	; Finalize AP initialization
	call smp_init_ap

	; Check whether there is an AP entry point
	mov rsi, config_table
	mov rsi, qword [config_table]
	mov rbx, qword [rsi + hydrogen_config_table.ap_entry]
	cmp rbx, 0
	je .halt_loop

	; Spin on barrier until the BSP is ready
	mov rsi, entry_barrier
.spin:
	lodsb
	cmp rax, 0
	je .spin

	; Jump to the kernel
	jmp rbx

	; Halt loop
.halt_loop:
	sti
.halt:
	hlt
	jmp .halt
