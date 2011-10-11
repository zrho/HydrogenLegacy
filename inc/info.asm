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
; Info Table - Main Table
;-------------------------------------------------------------------------------

; Flag indicating the presence of a 8259 PIC
%define INFO_FLAG_PIC (1 << 0)

; Main info structure containing important information about the system.
;
; .free_mem_begin	Beginning of the memory area, where it is free to write to
;					without having to fear to override some data.
; .command_line		The command line string with which the kernel has been loaded.
; .lapic_paddr		The physical address of the LAPIC.
; .flags			The system's flags.
; .proc_count		Length of processor list.
; .mod_count		Length of module list.
; .mmap_count		Length of memory map.
struc hydrogen_info_table
	.free_mem_begin:	RESB 8
	.command_line:		RESB 8
	.lapic_paddr:		RESB 8
	.flags:				RESB 1
	.proc_count:		RESB 1
	.mod_count:			RESB 1
	.mmap_count:		RESB 1
endstruc

;-------------------------------------------------------------------------------
; Info Table - Processor
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

;-------------------------------------------------------------------------------
; Info Table - Modules
;-------------------------------------------------------------------------------

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

;-------------------------------------------------------------------------------
; Info Table - Memory Map
;-------------------------------------------------------------------------------

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
