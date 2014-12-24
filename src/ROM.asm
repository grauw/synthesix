;
; Synthesix
;
; MIDI synthesizer for MSX
;

	INCLUDE "Macros.asm"

DEBUG: equ 1

ROM_CodeBank1: equ 0
ROM_CodeBank2: equ 1
ROM_CodeBank3: equ 2
ROM_CodeBank4: equ 3
ROM_MultiplyTableBank1: equ 4
ROM_MultiplyTableBank2: equ 5
ROM_RAMInitBank: equ 6
ROM_FontBank: equ 6
ROM_WaveTableBank: equ 7
ROM_SCCBank: equ 3FH

	org 4000H
ROM_HEADER: ds 10H
ROM_BANK0: ds 1F0H
ROM: ds 3B00H
ROM_TABLES: ds 300H
	org 0H
ZEROPAGE: ds 100H
TPA: ds 3F00H
	org 6000H
ROM_MULTIPLYTABLE: ds 4000H
	org 6000H
RAM_sourceAddress:
	org 0C000H
RAM_startAddress:
RAM: ds 1800H
RAM_endAddress:
	org 7800H
ROM_FONT: ds 800H
	org 6000H
ROM_WAVETABLES: ds 2000H

ROM_BANK_4000_CHANGE: equ 5000H
ROM_BANK_6000_CHANGE: equ 7000H

	SECTION ROM_HEADER

	db "AB"
	dw ROM_Main
	dw 0, 0, 0, 0, 0, 0

	ENDS

	SECTION ZEROPAGE

	INCLUDE "ZeroPage.asm"

	ENDS

	SECTION ROM

	INCLUDE "RAM.asm"
	INCLUDE "Synthesix.asm"
	INCLUDE "BIOS.asm"
	INCLUDE "System.asm"
	INCLUDE "Memory.asm"
	INCLUDE "ArrayList.asm"
	INCLUDE "VDP.asm"
	INCLUDE "Math.asm"
	INCLUDE "Heap.asm"
	INCLUDE "Class.asm"
	INCLUDE "Interrupt.asm"
	INCLUDE "MidiIn.asm"
	INCLUDE "MSXMidi.asm"
	INCLUDE "PhilipsMidi.asm"
	INCLUDE "SFGMidi.asm"
	INCLUDE "KeyMidi.asm"
	INCLUDE "AudioMidi.asm"
	INCLUDE "Channel.asm"
	INCLUDE "NotePool.asm"
	INCLUDE "Note.asm"
	INCLUDE "PSG.asm"
	INCLUDE "SCC.asm"
	INCLUDE "SCCVoice.asm"
	INCLUDE "Program.asm"
	INCLUDE "Patch.asm"
	INCLUDE "ModuleType.asm"
	INCLUDE "ModuleBank.asm"
	INCLUDE "Listeners.asm"
	INCLUDE "Updater.asm"

	ENDS

	SECTION TPA

	INCLUDE "modules/Modules.asm"
	INCLUDE "ui/UI.asm"

	ENDS

	SECTION ROM_BANK0

;
; Program entry point
;
ROM_Main:
	ei
	call ROM_Init

	call RAM_Init

	call Synthesix_Main

	call RAM_RestorePage0
	ret

;
ROM_Init:
	ld a,ROM_CodeBank1
	ld (ROM_BANK_4000_CHANGE),a
	ld a,ROM_CodeBank2
	ld (ROM_BANK_6000_CHANGE),a
	ret

	ENDS

	SECTION ROM_MULTIPLYTABLE

Math_multiply127x127Table:
	INCLUDE "multtable.asm"

	ENDS

	SECTION ROM_WAVETABLES

	INCLUDE "SCCWaveTables.asm"

	ENDS

	SECTION RAM

; The initial ROM banks
; Stored as words that include the bank select register address
; Example: ld hl,(ROM_bank6000) / ld (hl),l
ROM_bank4000:
	dw ROM_BANK_4000_CHANGE | ROM_CodeBank1
ROM_bank6000:
	dw ROM_BANK_6000_CHANGE | ROM_CodeBank2

	ENDS
