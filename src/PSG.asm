; Konami SCC mapper
PSG_REGISTER_SELECT: equ 0A0H
PSG_WRITE: equ 0A1H
PSG_READ: equ 0A2H

PSG_TONE_GENERATOR_CONTROL: equ 0
PSG_NOISE_GENERATOR_CONTROL: equ 6
PSG_MIXER_CONTROL: equ 7
PSG_AMPLITUDE_CONTROL: equ 8
PSG_ENVELOPE_PERIOD_CONTROL: equ 11
PSG_ENVELOPE_SHAPE_CONTROL: equ 13

PSG_Init:
	ld b,14
	ld hl,PSG_initValues
PSG_Init_Loop:
	ld a,14
	sub b
	out (PSG_REGISTER_SELECT),a
	ld a,(hl)
	out (PSG_WRITE),a
	inc hl
	djnz PSG_Init_Loop
	ret

PSG_Dump:
	ld b,14
PSG_Dump_Loop:
	ld a,14
	sub b
	out (PSG_REGISTER_SELECT),a
	in a,(PSG_READ)
	call System_PrintHexA
	ld a," "
	call System_PrintChar
	djnz PSG_Dump_Loop
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
PSGVoice_NoteOn:
	; frequency
	ld h,PSG_frequencyTable / 100H
	ld l,a
	sla l
	ld a,(ix + PSGVoice_frequencyLSB)
	out (PSG_REGISTER_SELECT),a
	ld a,(hl)
	inc l
	out (PSG_WRITE),a
	ld a,(ix + PSGVoice_frequencyMSB)
	out (PSG_REGISTER_SELECT),a
	ld a,(hl)
	out (PSG_WRITE),a

	; volume
	ld a,(ix + PSGVoice_level)
	out (PSG_REGISTER_SELECT),a
	ld h,PSG_volumeTable / 100H
	ld l,b
	ld a,(hl)
	out (PSG_WRITE),a

	; note on
	ld a,PSG_MIXER_CONTROL
	out (PSG_REGISTER_SELECT),a
	in a,(PSG_READ)
	and (ix + PSGVoice_mixerAndMask)
	out (PSG_WRITE),a
	ret

; ix = this
PSGVoice_NoteOff:
	ld a,PSG_MIXER_CONTROL
	out (PSG_REGISTER_SELECT),a
	in a,(PSG_READ)
	or (ix + PSGVoice_mixerOrMask)
	out (PSG_WRITE),a
	ret

;
;
;

PSGVoice:
PSGVoice_frequencyLSB: equ $ - PSGVoice
	db PSG_TONE_GENERATOR_CONTROL + 0
PSGVoice_frequencyMSB: equ $ - PSGVoice
	db PSG_TONE_GENERATOR_CONTROL + 1
PSGVoice_level: equ $ - PSGVoice
	db PSG_AMPLITUDE_CONTROL + 0
PSGVoice_mixerOrMask:equ $ - PSGVoice
	db 00000001B
PSGVoice_mixerAndMask:equ $ - PSGVoice
	db 11111110B

PSG_voice1: equ PSGVoice

PSG_voice2:
	db PSG_TONE_GENERATOR_CONTROL + 2
	db PSG_TONE_GENERATOR_CONTROL + 3
	db PSG_AMPLITUDE_CONTROL + 1
	db 00000010B
	db 11111101B

PSG_voice3:
	db PSG_TONE_GENERATOR_CONTROL + 4
	db PSG_TONE_GENERATOR_CONTROL + 5
	db PSG_AMPLITUDE_CONTROL + 2
	db 00000100B
	db 11111011B

PSG_initValues:
	db 0, 0, 0, 0, 0, 0  ; tone frequency (x3)
	db 0                 ; noise frequency
	db 10111111B         ; mixer control 1, 0, noise (x3), tone (x3)
	db 0, 0, 0           ; level (x3)
	db 0BH, 00H          ; envelope frequency
	db 0B8H              ; envelope shape

	ds -$ & 0FFH  ; align 100H
PSG_frequencyTable:
	INCLUDE "psgftable.asm"

	ds -$ & 0FFH  ; align 100H
PSG_volumeTable:
	db  0,  1,  3,  4,  5,  6,  6,  7,  7,  7,  8,  8,  8,  8,  9,  9
	db  9,  9,  9,  9, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11
	db 11, 11, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12
	db 12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 13
	db 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 14, 14, 14
	db 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14
	db 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15
	db 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
