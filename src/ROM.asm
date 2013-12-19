;
; Synthesix
;
; MIDI synthesizer for MSX
;

ROM_BANK_0_CHANGE: equ 5000H
ROM_BANK_1_CHANGE: equ 7000H
ROM_BANK_2_CHANGE: equ 9000H
ROM_BANK_3_CHANGE: equ 0B000H

ROM_Bank0Default: equ ROM_CodeBank1
ROM_Bank1Default: equ ROM_CodeBank2
ROM_Bank2Default: equ ROM_SCCBank
ROM_Bank3Default: equ ROM_MultiplyTableBank

	INCLUDE "Macros.asm"

ROM_CodeBank1: equ 0
ROM_CodeBank2: equ 1
	org 4000H

	db "AB"
	dw Synthesix_Main
	dw 0, 0, 0, 0, 0, 0

	INCLUDE "Synthesix.asm"
	INCLUDE "System.asm"
	INCLUDE "Math.asm"
	INCLUDE "Heap.asm"
	INCLUDE "Class.asm"
	INCLUDE "Keys.asm"
	INCLUDE "Channel.asm"
	INCLUDE "Patch.asm"
	INCLUDE "SCCPatch.asm"
	INCLUDE "PSG.asm"
	INCLUDE "SCC.asm"
	INCLUDE "SCCVoice.asm"
	INCLUDE "SCCWaveTables.asm"
	PAD 8000H

ROM_RAMInitBank: equ 2
	INCLUDE "RAM.asm"
	PAD 0A000H

ROM_MultiplyTableBank: equ 3
Math_multiply127x127Table:
	INCLUDE "multtable.asm"
	PAD 0C000H

ROM_SCCBank: equ 3FH
