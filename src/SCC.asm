; Konami SCC mapper
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

SCC_MAX_VOICES: equ 4

SCC_Init:
	ld a,ROM_SCCBank
	ld (ROM_BANK_2_CHANGE),a

	ld iy,SCCVoice
	call Class_New
	ld (SCC_voices + 0),ix
	ld b,SCC_WAVE_1
	ld c,SCC_FREQUENCY_1
	ld d,SCC_LEVEL_1
	ld e,00000001B
	call SCCVoice_Constructor

	call Class_New
	ld (SCC_voices + 2),ix
	ld b,SCC_WAVE_2
	ld c,SCC_FREQUENCY_2
	ld d,SCC_LEVEL_2
	ld e,00000010B
	call SCCVoice_Constructor

	call Class_New
	ld (SCC_voices + 4),ix
	ld b,SCC_WAVE_3
	ld c,SCC_FREQUENCY_3
	ld d,SCC_LEVEL_3
	ld e,00000100B
	call SCCVoice_Constructor

	call Class_New
	ld (SCC_voices + 6),ix
	ld b,SCC_WAVE_4_5
	ld c,SCC_FREQUENCY_4
	ld d,SCC_LEVEL_4
	ld e,00001000B
	call SCCVoice_Constructor
	ret

SCC_GetFreeVoice:
	REPT SCC_MAX_VOICES, ?voice
	ld ix,(SCC_voices + ?voice * 2)
	bit 7,(ix + SCCVoice_free)
	ret z
	ENDM
	call System_ThrowException
