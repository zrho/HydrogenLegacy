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
; I/O APIC - Registers
;-------------------------------------------------------------------------------

; Memory Mapped Registers
;
; .regsel	Selects a register for the IO window.
; .iowin	Window for manipulating the I/O APIC's internal registers.
struc ioapic
	.regsel:			RESB 4
	.iowin:				RESB 4
endstruc

; Internal Registers
%define IOAPIC_IOAPICID_INDEX			0x00
%define IOAPIC_IOAPICVER_INDEX			0x01
%define IOAPIC_IOAPICARB_INDEX			0x02
%define IOAPIC_IOREDTBL_OFFSET			0x10
