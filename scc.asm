; Konami SCC mapper
ROM_BANK_0_CHANGE: equ 5000H
ROM_BANK_1_CHANGE: equ 7000H
ROM_BANK_2_CHANGE: equ 9000H
ROM_BANK_3_CHANGE: equ 0B000H

SCC_WAVE_1: equ 9800H
SCC_WAVE_2: equ 9820H
SCC_WAVE_3: equ 9840H
SCC_WAVE_4_5: equ 9860H
SCC_FREQUENCY_1: equ 9880H
SCC_FREQUENCY_2: equ 9882H
SCC_FREQUENCY_3: equ 9884H
SCC_FREQUENCY_4: equ 9886H
SCC_FREQUENCY_5: equ 9888H
SCC_LEVEL_1: equ 988AH
SCC_LEVEL_2: equ 988BH
SCC_LEVEL_3: equ 988CH
SCC_LEVEL_4: equ 988DH
SCC_LEVEL_5: equ 988EH
SCC_MIXER: equ 988FH
SCC_DEFORMATION: equ 98E0H

SCC_Init:
	in a,(PPI_PORT_A)
	and 00001100B
	rrca
	rrca
	ld hl,EXPTBL + 1
	or (hl)
	jp p,SCC_Init_noSubslot
	ld b,a
	ld a,(SLTTBL + 1)
	and 00001100B
	or b
SCC_Init_noSubslot:
	ld h,80H
	call ENASLT
	ei
	ld a,3FH
	ld (ROM_BANK_2_CHANGE),a
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
SCCTone_NoteOn:
	; de = frequency
	ld h,PSG_frequencyTable / 100H
	ld l,a
	sla l
	ld e,(hl)
	inc hl
	ld d,(hl)

	; a = volume
	ld a,b
	rrca
	rrca
	rrca

	ld l,(ix + SCCTone_frequency)
	ld h,(ix + SCCTone_frequency + 1)
	ld (hl),e
	inc hl
	ld (hl),d

	ld l,(ix + SCCTone_level)
	ld h,(ix + SCCTone_level + 1)
	ld (hl),a

	ld a,(SCC_mixerCopy)
	or (ix + SCCTone_mixerOrMask)
	ld (SCC_MIXER),a
	ld (SCC_mixerCopy),a
	ret

; ix = this
SCCTone_NoteOff:
	ld a,(SCC_mixerCopy)
	and (ix + SCCTone_mixerAndMask)
	ld (SCC_MIXER),a
	ld (SCC_mixerCopy),a
	ret

; ix = this
; a = program number (0-127)
SCCTone_ProgramChange:
	sla a
	ld h,SCC_presetPrograms / 100H
	ld l,a
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	call SCCTone_LoadWave
	ret

; ix = this
; hl = wave address
SCCTone_LoadWave:
	ld e,(ix + SCCTone_wave)
	ld d,(ix + SCCTone_wave + 1)
	ld bc,32
	ldir
	ret

;
;
;

SCC_tone1:
SCCTone:
SCCTone_wave: equ $ - SCCTone
	dw SCC_WAVE_1
SCCTone_frequency: equ $ - SCCTone
	dw SCC_FREQUENCY_1
SCCTone_level: equ $ - SCCTone
	dw SCC_LEVEL_1
SCCTone_mixerOrMask: equ $ - SCCTone
	db 00000001B
SCCTone_mixerAndMask: equ $ - SCCTone
	db 11111110B

SCC_tone2:
	dw SCC_WAVE_2
	dw SCC_FREQUENCY_2
	dw SCC_LEVEL_2
	db 00000010B
	db 11111101B

SCC_tone3:
	dw SCC_WAVE_3
	dw SCC_FREQUENCY_3
	dw SCC_LEVEL_3
	db 00000100B
	db 11111011B

SCC_tone4:
	dw SCC_WAVE_4_5
	dw SCC_FREQUENCY_4
	dw SCC_LEVEL_4
	db 00001000B
	db 11110111B

	ds -$ & 0FFH  ; align 100H
SCC_presetPrograms:
	dw SCC_squareWave, SCC_sawWave, SCC_sineWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave
	dw SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_squareWave, SCC_initWave

SCC_squareWave:
	db 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH
	db 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H

SCC_sawWave:
	db 04H, 0CH, 14H, 1CH, 25H, 2DH, 35H, 3DH, 45H, 4EH, 56H, 5EH, 66H, 6FH, 77H, 7FH
	db 80H, 88H, 90H, 99H, 0A1H, 0A9H, 0B1H, 0BAH, 0C2H, 0CAH, 0D2H, 0DAH, 0E3H, 0EBH, 0F3H, 0FBH

SCC_sineWave:
	db 19H, 31H, 47H, 5AH, 6AH, 76H, 7DH, 7FH, 7DH, 76H, 6AH, 5AH, 47H, 31H, 19H, 00H
	db 0E7H, 0CFH, 0B9H, 0A6H, 96H, 8AH, 83H, 80H, 83H, 8AH, 96H, 0A6H, 0B9H, 0CFH, 0E7H, 00H

SCC_initWave:
	ds 32, 0
