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
ROM_HEADER: ds 10H
ROM_BANK0: ds 1F0H
ROM: ds 3E00H
	org 6000H
RAM_sourceAddress:
	org 0C000H
RAM_startAddress:
RAM: ds 2000H
RAM_endAddress:
	org 06000H
ROM_MULTIPLYTABLE: ds 2000H
	org 06000H
ROM_WAVETABLES: ds 2000H

Heap_size: equ 1000H

ROM_BANK_4000_CHANGE: equ 5000H
ROM_BANK_6000_CHANGE: equ 7000H
ROM_BANK_8000_CHANGE: equ 9000H
ROM_BANK_A000_CHANGE: equ 0B000H

	SECTION ROM_HEADER

	db "AB"
	dw Synthesix_Main
	dw 0, 0, 0, 0, 0, 0

	ENDS

	SECTION ROM

	INCLUDE "Synthesix.asm"
	INCLUDE "BIOS.asm"
	INCLUDE "System.asm"
	INCLUDE "Memory.asm"
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
	INCLUDE "Channel.asm"
	INCLUDE "NotePool.asm"
	INCLUDE "Note.asm"
	INCLUDE "PSG.asm"
	INCLUDE "SCC.asm"
	INCLUDE "SCCVoice.asm"
	INCLUDE "Program.asm"
	INCLUDE "Patch.asm"
	INCLUDE "PatchModules.asm"
	INCLUDE "Module.asm"
	INCLUDE "Listeners.asm"
	INCLUDE "Clock.asm"
	INCLUDE "modulation/Value.asm"
	INCLUDE "modulation/Attenuate.asm"
	INCLUDE "modulation/AttenuateAdd.asm"
	INCLUDE "modulation/AddPitch.asm"
	INCLUDE "modulation/Or.asm"
	INCLUDE "modulation/Sustain.asm"
	INCLUDE "modulation/ControllerBank.asm"
	INCLUDE "modulation/EnvelopeAD.asm"
	INCLUDE "modulation/EnvelopeAR.asm"
	INCLUDE "modulation/LFOTriangle.asm"
	INCLUDE "modulation/LFOTriangleSigned.asm"
	INCLUDE "modulation/PitchBend.asm"
	INCLUDE "ui/UI.asm"

	ENDS

	SECTION ROM_BANK0

ROM_Init:
	ld a,ROM_CodeBank1
	ld (ROM_BANK_4000_CHANGE),a
	ld a,ROM_CodeBank2
	ld (ROM_BANK_6000_CHANGE),a
	ld a,ROM_RAMInitBank
	ld (ROM_BANK_8000_CHANGE),a
	ld a,ROM_MultiplyTableBank
	ld (ROM_BANK_A000_CHANGE),a
	ret

;
; Copy RAM initialisation data from ROM to RAM.
; These values are defined in the RAM section and copied on boot.
;
RAM_Init:
	ld a,ROM_RAMInitBank
	ld (ROM_BANK_6000_CHANGE),a
	ld hl,RAM_sourceAddress
	ld de,RAM_startAddress
	ld bc,RAM_endAddress - RAM_startAddress
	ldir
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
ROM_bank8000:
	dw ROM_BANK_8000_CHANGE | ROM_RAMInitBank
ROM_bankA000:
	dw ROM_BANK_A000_CHANGE | ROM_MultiplyTableBank

	ENDS
