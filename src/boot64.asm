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
	cli										; Clear interrupts
	and rsp, ~0xFFF							; Reset stack

	;call multiboot_parse					; Parse multiboot tables
	call acpi_parse							; Parse ACPI tables
	;call modules_move						; Move modules to new location

	call int_init							; Initialize IDT
	call int_load							; Load IDT

	jmp $
