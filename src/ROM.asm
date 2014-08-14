;
; Synthesix
;
; MIDI synthesizer for MSX
;

	INCLUDE "Macros.asm"

DEBUG: equ 1

ROM_CodeBank1: equ 0
ROM_CodeBank2: equ 1
ROM_MultiplyTableBank1: equ 2
ROM_MultiplyTableBank2: equ 3
ROM_RAMInitBank: equ 4
ROM_FontBank: equ 4
ROM_WaveTableBank: equ 5
ROM_SCCBank: equ 3FH

	org 4000H
ROM_HEADER: ds 10H
ROM_BANK0: ds 1F0H
ROM: ds 3E00H
	org 06000H
ROM_MULTIPLYTABLE: ds 4000H
	org 6000H
RAM_sourceAddress:
	org 0C000H
RAM_startAddress:
RAM: ds 1800H
RAM_endAddress:
	org 7800H
ROM_FONT: ds 800H
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
	INCLUDE "Clock.asm"
	INCLUDE "modules/Value.asm"
	INCLUDE "modules/Constants.asm"
	INCLUDE "modules/Attenuate.asm"
	INCLUDE "modules/AttenuateAdd.asm"
	INCLUDE "modules/AddPitch.asm"
	INCLUDE "modules/Or.asm"
	INCLUDE "modules/Sustain.asm"
	INCLUDE "modules/ControllerBank.asm"
	INCLUDE "modules/MultCounter.asm"
	INCLUDE "modules/DivCounter.asm"
	INCLUDE "modules/EnvelopeAD.asm"
	INCLUDE "modules/EnvelopeAR.asm"
	INCLUDE "modules/LFOTriangle.asm"
	INCLUDE "modules/LFOTriangleBipolar.asm"
	INCLUDE "modules/WaveSine.asm"
	INCLUDE "modules/WaveSineBipolar.asm"
	INCLUDE "modules/WaveSquare.asm"
	INCLUDE "modules/WaveSquareBipolar.asm"
	INCLUDE "modules/WavePulse.asm"
	INCLUDE "modules/WavePulseBipolar.asm"
	INCLUDE "modules/WaveSaw.asm"
	INCLUDE "modules/WaveSawBipolar.asm"
	INCLUDE "modules/WaveTriangle.asm"
	INCLUDE "modules/WaveTriangleBipolar.asm"
	INCLUDE "modules/PitchBend.asm"
	INCLUDE "ui/UI.asm"

	ENDS

	SECTION ROM_BANK0

ROM_Init:
	ld a,ROM_CodeBank1
	ld (ROM_BANK_4000_CHANGE),a
	ld a,ROM_CodeBank2
	ld (ROM_BANK_6000_CHANGE),a
	ld a,ROM_MultiplyTableBank1
	ld (ROM_BANK_8000_CHANGE),a
	ld a,ROM_MultiplyTableBank2
	ld (ROM_BANK_A000_CHANGE),a
	ret

;
; Copy RAM initialisation data from ROM to RAM.
; These values are defined in the RAM section and copied on boot.
;
RAM_Init:
	and a
	ld hl,(HIMEM)
	ld bc,RAM_endAddress
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
ROM_bank8000:
	dw ROM_BANK_8000_CHANGE | ROM_MultiplyTableBank1
ROM_bankA000:
	dw ROM_BANK_A000_CHANGE | ROM_MultiplyTableBank2

	ENDS
