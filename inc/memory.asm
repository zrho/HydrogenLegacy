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

; Video Memory
%define MEMORY_SCREEN_PADDR			0xb8000

;-------------------------------------------------------------------------------
; Memory Layout - Virtual
;-------------------------------------------------------------------------------

; Kernel entry point address (virtual)
%define MEMORY_KERNEL_ENTRY_VADDR	0xFFFFFF0000000000
