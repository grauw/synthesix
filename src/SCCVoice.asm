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
