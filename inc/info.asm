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
; Info Table - Flags
;-------------------------------------------------------------------------------

; Flag indicating the presence of a 8259 PIC
%define INFO_FLAG_PIC (1 << 0)

;-------------------------------------------------------------------------------
; Info Table - Secondary Info Structures
;-------------------------------------------------------------------------------

%define INFO_PROC_FLAG_PRESENT	(1 << 0)
%define INFO_PROC_FLAG_BSP		(1 << 1)
%define INFO_PROC_FLAG_READY	(1 << 2)

; Info structure describing a processor.
;
; .acpi_id		The ACPI id of the processor.
; .apic_id		The APIC id of the processor.
struc hydrogen_info_proc
	.acpi_id					RESB	1
	.apic_id					RESB	1
	.flags						RESB	2
endstruc

; Info structure describing a module.
;
; .begin		The 64 bit physical address the module begins at.
; .length		The length of the module in bytes.
; .cmdline		The path of the module file and its arguments.
struc hydrogen_info_mod
	.begin						RESB	8
	.length						RESB 	8
	.cmdline					RESB	8
endstruc

; Info structure descibing an entry in the memory map.
;
; .begin		The 64 bit physical address the covered section begins at.
; .length		The length of the covered section.
; .available	One, if the section is available for free usage; zero otherwise.
struc hydrogen_info_mmap
	.begin						RESB	8
	.length						RESB	8
	.available					RESB	1
endstruc

; Macro for retrieving the address of a process descriptor for a processor
; with a given id.
;
; Parameters:
; 	%1 Register to load the address to.
;	%2 APIC id of the processor or register containing the id.
;
; Examples:
; 	info_proc_addr rdi, 0x2
; 	info_proc_addr rsi, rax
%macro info_proc_addr 2
	mov %1, %2				; Load index into target register
	shl %1, 2				; Multiply with four to get offset
	add %1, info_proc		; Add list address
%endmacro
