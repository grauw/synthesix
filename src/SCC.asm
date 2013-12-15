; Konami SCC mapper
ROM_BANK_0_CHANGE: equ 5000H
ROM_BANK_1_CHANGE: equ 7000H
ROM_BANK_2_CHANGE: equ 9000H
ROM_BANK_3_CHANGE: equ 0B000H

SCC_BASE: equ 9800H
SCC_BASE_MSB: equ SCC_BASE / 100H
SCC_WAVE_1: equ 00H
SCC_WAVE_2: equ 20H
SCC_WAVE_3: equ 40H
SCC_WAVE_4_5: equ 60H
SCC_FREQUENCY_1: equ 80H
SCC_FREQUENCY_2: equ 82H
SCC_FREQUENCY_3: equ 84H
SCC_FREQUENCY_4: equ 86H
SCC_FREQUENCY_5: equ 88H
SCC_LEVEL_1: equ 8AH
SCC_LEVEL_2: equ 8BH
SCC_LEVEL_3: equ 8CH
SCC_LEVEL_4: equ 8DH
SCC_LEVEL_5: equ 8EH
SCC_MIXER: equ 8FH
SCC_DEFORMATION: equ 0E0H

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

	ld hl,SCC_sawWave
	ld ix,SCC_voice1
	call SCCVoice_LoadWave
	ld hl,SCC_sawWave
	ld ix,SCC_voice2
	call SCCVoice_LoadWave
	ld hl,SCC_sawWave
	ld ix,SCC_voice3
	call SCCVoice_LoadWave
	ld hl,SCC_sawWave
	ld ix,SCC_voice4
	call SCCVoice_LoadWave
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
SCCVoice_NoteOn:
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

	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice_frequency)
	ld (hl),e
	inc hl
	ld (hl),d

	ld l,(ix + SCCVoice_level)
	ld (hl),a

	ld a,(SCC_mixerCopy)
	or (ix + SCCVoice_mixerOrMask)
	ld (SCC_BASE + SCC_MIXER),a
	ld (SCC_mixerCopy),a
	ret

; ix = this
SCCVoice_NoteOff:
	ld a,(SCC_mixerCopy)
	and (ix + SCCVoice_mixerAndMask)
	ld (SCC_BASE + SCC_MIXER),a
	ld (SCC_mixerCopy),a
	ret

; ix = this
; hl = wave address
SCCVoice_LoadWave:
	ld e,(ix + SCCVoice_wave)
	ld d,SCC_BASE_MSB
	ld bc,32
	ldir
	ret

;
;
;

SCC_voice1:
SCCVoice:
SCCVoice_wave: equ $ - SCCVoice
	db SCC_WAVE_1
SCCVoice_frequency: equ $ - SCCVoice
	db SCC_FREQUENCY_1
SCCVoice_level: equ $ - SCCVoice
	db SCC_LEVEL_1
SCCVoice_mixerOrMask: equ $ - SCCVoice
	db 00000001B
SCCVoice_mixerAndMask: equ $ - SCCVoice
	db 11111110B

SCC_voice2:
	db SCC_WAVE_2
	db SCC_FREQUENCY_2
	db SCC_LEVEL_2
	db 00000010B
	db 11111101B

SCC_voice3:
	db SCC_WAVE_3
	db SCC_FREQUENCY_3
	db SCC_LEVEL_3
	db 00000100B
	db 11111011B

SCC_voice4:
	db SCC_WAVE_4_5
	db SCC_FREQUENCY_4
	db SCC_LEVEL_4
	db 00001000B
	db 11110111B

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
