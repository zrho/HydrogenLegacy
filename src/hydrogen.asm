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
; Headers
;-------------------------------------------------------------------------------
%include "../inc/memory.asm"
%include "../inc/info.asm"
%include "../inc/screen.asm"
%include "../inc/acpi.asm"
%include "../inc/page.asm"
%include "../inc/multiboot.asm"

;-------------------------------------------------------------------------------
; Code
;-------------------------------------------------------------------------------
%include "boot32.asm"
%include "boot64.asm"
%include "interrupts.asm"
%include "screen.asm"
%include "acpi.asm"

;-------------------------------------------------------------------------------
; Data and BSS
;-------------------------------------------------------------------------------
%include "data.asm"
%include "bss.asm"
