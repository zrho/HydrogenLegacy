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
; Memory Layout - Physical
;-------------------------------------------------------------------------------

; Physical addresses of Hydrogen info tables
;%define MEMORY_INFO_TABLE_PADDR		0x8000
;%define MEMORY_INFO_PROC_PADDR		0x9000
;%define MEMORY_INFO_MODS_PADDR		0xA000
;%define MEMORY_INFO_MMAP_PADDR		0xB000

; Physical addresses of system tables and their pointers
;%define MEMORY_SYS_IDT_PADDR		0xC000
;%define MEMORY_SYS_GDT_PADDR		0xD000

; Physical addresses of boot paging structures
;%define MEMORY_PAGE_PML4_PADDR		0xE000
;%define MEMORY_PAGE_PDP_IDN_PADDR	0xF000
;%define MEMORY_PAGE_PD_IDN_PADDR	0x10000 ; 0x1000 x 64

; Stacks
;%define MEMORY_STACK_PADDR			0x50000 ; 0x1000 x 32 (max)

; Video Memory
%define MEMORY_SCREEN_PADDR			0xb8000
