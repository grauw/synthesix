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

	call Memory_GetSlotPage3
	ld h,80H
	call Memory_SetSlot
	call ROM_InitRAM

	call ROM_InitPage0

	call Synthesix_Main

	call ROM_RestorePage0
	ret

;
ROM_Init:
	ld a,ROM_CodeBank1
	ld (ROM_BANK_4000_CHANGE),a
	ld a,ROM_CodeBank2
	ld (ROM_BANK_6000_CHANGE),a
	ret

;
; Copy RAM initialisation data from ROM to RAM.
; These values are defined in the RAM section and copied on boot.
;
ROM_InitRAM:
	and a
	ld hl,0
	add hl,sp
	ld bc,RAM_endAddress + 100H
	sbc hl,bc
	ld hl,RAM_insufficientTPA
	call c,System_ThrowExceptionWithMessage

	ld a,ROM_RAMInitBank
	ld (ROM_BANK_6000_CHANGE),a
	ld hl,RAM_sourceAddress
	ld de,RAM_startAddress
	ld bc,RAM_endAddress - RAM_startAddress
	ldir
	ld a,ROM_CodeBank2
	ld (ROM_BANK_6000_CHANGE),a
	ret

;
ROM_InitPage0:
	di
	call Memory_GetSlotPage3
	ld h,00H
	call Memory_SetSlot
	ld a,ROM_CodeBank3
	ld (ROM_BANK_6000_CHANGE),a
	ld hl,6000H + DEBUG  ; skip 1st byte just to avoid breakpoint
	ld de,0000H + DEBUG
	ld bc,2000H - DEBUG
	ldir
	ld a,ROM_CodeBank4
	ld (ROM_BANK_6000_CHANGE),a
	ld hl,6000H
	ld de,2000H
	ld bc,2000H
	ldir
	ld a,ROM_CodeBank2
	ld (ROM_BANK_6000_CHANGE),a
	ei
	ret

;
ROM_RestorePage0:
	ld a,(EXPTBL)
	ld h,00H
	call Memory_SetSlot
	ret

	ENDS

	SECTION ROM

RAM_insufficientTPA:
	db "Insufficient TPA memory.",0

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
