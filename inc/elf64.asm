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

; Value for elf64_ehdr.e_ident_mag
%define ELFMAG					0x464C457F	; 0x7F + 'ELF'

; Values for elf64_ehdr.e_indent_class
%define ELFCLASSNONE			0	; Unknown
%define ELFCLASS32				1	; 32 bit arch
%define ELFCLASS64				2	; 64 bit arch

; Values for elf64_ehdr.e_ident_data
%define ELFDATANONE				0	; Unknown
%define ELFDATA2LSB				1	; Little Endian
%define ELFDATA2MSB				2	; Big Endian

; Values for elf64_ehdr.e_type
%define ELF_ET_NONE				0	; Unknown
%define ELF_ET_REL				1	; Relocatable
%define ELF_ET_EXEC				2	; Executable
%define ELF_ET_DYN				3	; Shared Object
%define ELF_ET_CORE				4	; Core File

; Values for elf64_phdr.p_type
%define ELF_PT_NULL				0	; Unused entry
%define ELF_PT_LOAD				1	; Loadable segment
%define ELF_PT_DYNAMIC			2	; Dynamic linking information segment
%define ELF_PT_INTERP			3	; Pathname of interpreter
%define ELF_PT_NOTE				4	; Auxiliary information
%define ELF_PT_SHLIB			5	; Reserved (not used)
%define ELF_PT_PHDR				6	; Location of program header itself

; Values for elf64_phdr.p_flags
%define ELF_PF_X				(1 << 0)	; Executable
%define ELF_PF_W				(1 << 1)	; Writable
%define ELF_PF_R				(1 << 2)	; Readable

; ELF64 file header.
struc elf64_ehdr
	.e_ident_mag:				RESB 4
	.e_ident_class:				RESB 1
	.e_ident_data:				RESB 1
	.e_ident_version:			RESB 1
	.e_ident_osabi:				RESB 1
	.e_ident_abiversion:		RESB 1
	.e_ident_pad:				RESB 7

	.e_type:					RESB 2
	.e_machine:					RESB 2
	.e_version:					RESB 4
	.e_entry:					RESB 8
	.e_phoff:					RESB 8
	.e_shoff:					RESB 8
	.e_flags:					RESB 4

	.e_ehsize:					RESB 2
	.e_phsize:					RESB 2
	.e_phnum:					RESB 2
	.e_shentsize:				RESB 2
	.e_shnum:					RESB 2
	.e_shstrndx:				RESB 2
	.end:
endstruc

; ELF64 program header.
;
; Contains information on where to load the binary's data and code from and where
; to map it to.
struc elf64_phdr
	.p_type:					RESB 4
	.p_flags:					RESB 4
	.p_offset:					RESB 8
	.p_vaddr:					RESB 8
	.p_paddr:					RESB 8
	.p_filesz:					RESB 8
	.p_memsz:					RESB 8
	.p_align:					RESB 8
	.end:
endstruc
