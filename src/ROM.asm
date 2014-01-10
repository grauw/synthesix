;
; Synthesix
;
; MIDI synthesizer for MSX
;

	INCLUDE "Macros.asm"

ROM_CodeBank1: equ 0
ROM_CodeBank2: equ 1
ROM_RAMInitBank: equ 2
ROM_MultiplyTableBank: equ 3
ROM_WaveTableBank: equ 4
ROM_SCCBank: equ 3FH

	org 4000H
ROM: ds 4000H
RAM_sourceAddress:
	org 0C000H
RAM_startAddress:
RAM: ds 2000H
RAM_endAddress:
	org 0A000H
ROM_MULTIPLYTABLE: ds 2000H
	org 0A000H
ROM_WAVETABLES: ds 2000H

ROM_BANK_0_CHANGE: equ 5000H
ROM_BANK_1_CHANGE: equ 7000H
ROM_BANK_2_CHANGE: equ 9000H
ROM_BANK_3_CHANGE: equ 0B000H

ROM_Bank0Default: equ ROM_CodeBank1
ROM_Bank1Default: equ ROM_CodeBank2
ROM_Bank2Default: equ ROM_SCCBank
ROM_Bank3Default: equ ROM_MultiplyTableBank

	SECTION ROM

	db "AB"
	dw Synthesix_Main
	dw 0, 0, 0, 0, 0, 0

	INCLUDE "Synthesix.asm"
	INCLUDE "System.asm"
	INCLUDE "VDP.asm"
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
	INCLUDE "AREnvelope.asm"
	INCLUDE "MidiIn.asm"
	INCLUDE "MSXMIDI.asm"
	INCLUDE "ui/UI.asm"

;
; All RAM data is defined inside the marked section below
; These values are copied to RAM during program initialisation
;

RAM_Init:
	ld hl,RAM_sourceAddress
	ld de,RAM_startAddress
	ld bc,RAM_endAddress - RAM_startAddress
	ldir
	ret

	ENDS

	SECTION RAM

; The initial ROM banks
; Stored as words that include the bank select register address
; Example: ld hl,(ROM_bank3) / ld (hl),l
ROM_bank1:
	dw 5000H
ROM_bank2:
	dw 7001H
ROM_bank3:
	dw 9002H
ROM_bank4:
	dw 0B003H

;============================================
; HEAP MUST BE THE LAST THING DEFINED IN RAM
;============================================
Heap_start:

	ENDS

	SECTION ROM_MULTIPLYTABLE

Math_multiply127x127Table:
	INCLUDE "multtable.asm"

	ENDS

	SECTION ROM_WAVETABLES

	INCLUDE "SCCWaveTables.asm"

	ENDS
