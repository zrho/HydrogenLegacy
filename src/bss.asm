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

section .bss
bits 64

;-------------------------------------------------------------------------------
; BSS - Info Tables
;-------------------------------------------------------------------------------

; The info table to be passed to the kernel.
info_table:
	.free_mem_begin:	resb 4
	.command_line:		resb 4
	.lapic_paddr:		resb 4
	.idtr_paddr:		resb 4
	.gdtr_paddr:		resb 4
	.flags:				resb 1
	.proc_count:		resb 1
	.mod_count:			resb 1
	.mmap_count:		resb 1
	.reserved:			resb 4096 - 24

info_proc:		resb 0x1000
info_mods:		resb 0x1000
info_mmap:		resb 0x1000
info_strings:	resb 0x1000

;-------------------------------------------------------------------------------
; BSS - System Tables
;-------------------------------------------------------------------------------

sys_idt64:	resb 0x1000
sys_gdt64:	resb 0x1000

;-------------------------------------------------------------------------------
; BSS - Paging
;-------------------------------------------------------------------------------

paging_pml4:		resb 0x1000
paging_pdp_idn:		resb 0x1000
paging_pd_idn:		resb (0x1000 * 64)
paging_pdp_kernel: 	resb 0x1000
paging_pd_kernel:	resb 0x1000
paging_pt_kernel:	resb 0x1000

;-------------------------------------------------------------------------------
; BSS - Stacks
;-------------------------------------------------------------------------------

stack_heap:		resb (0x1000 * 32)
