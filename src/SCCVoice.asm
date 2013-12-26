;
; An SCC voice (channel)
;
	dw SCCVoice_size
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
SCCVoice_velocity: equ $ - SCCVoice
	db 0
SCCVoice_attack: equ $ - SCCVoice
	db 255 / 30  ; inverse speed
SCCVoice_release: equ $ - SCCVoice
	db 255 / 30  ; inverse speed
SCCVoice_envelopePhase: equ $ - SCCVoice
	db 0
SCCVoice_envelopeCounter: equ $ - SCCVoice
	db 0
SCCVoice_free: equ $ - SCCVoice
	db 0
SCCVoice_size: equ $ - SCCVoice

; ix = this
; b = wave register
; c = frequency register
; d = level register
; e = mixer or mask
; ix <- this
SCCVoice_Constructor:
	ld (ix + SCCVoice_wave),b
	ld (ix + SCCVoice_frequency),c
	ld (ix + SCCVoice_level),d
	ld (ix + SCCVoice_mixerOrMask),e
	ld a,e
	xor 0FFH
	ld (ix + SCCVoice_mixerAndMask),a
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
SCCVoice_NoteOn:
	ld (ix + SCCVoice_velocity),b
	ld (ix + SCCVoice_envelopePhase),0

	; de = frequency
	ld h,PSG_frequencyTable / 100H
	rlca
	ld l,a
	ld e,(hl)
	inc l
	ld d,(hl)

	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice_frequency)
	ld (hl),e
	inc l
	ld (hl),d

	ld (ix + SCCVoice_envelopeCounter),0
	ld b,1
	call SCCVoice_UpdateAttack

	ld a,(SCC_mixerCopy)
	or (ix + SCCVoice_mixerOrMask)
	ld (SCC_BASE + SCC_MIXER),a
	ld (SCC_mixerCopy),a
	ret

; ix = this
SCCVoice_NoteOff:
	ld (ix + SCCVoice_envelopePhase),255
	ld b,1
	call SCCVoice_UpdateRelease
	ret

; ix = this
; b = time delta
SCCVoice_Update:
	bit 7,(ix + SCCVoice_envelopePhase)
	jr nz,SCCVoice_UpdateRelease
	jp SCCVoice_UpdateAttack

; ix = this
; b = time delta
SCCVoice_UpdateAttack:
	ld a,(ix + SCCVoice_envelopeCounter)
	ld h,b
SCCVoice_UpdateAttack_Loop:
	add a,(ix + SCCVoice_attack)
	jr c,SCCVoice_UpdateAttack_Complete
	djnz SCCVoice_UpdateAttack_Loop
	ld b,h
	ld (ix + SCCVoice_envelopeCounter),a
	rra
	call SCCVoice_SetLevel
	ret
SCCVoice_UpdateAttack_Complete:
	ld b,h
	ld (ix + SCCVoice_envelopeCounter),255
	ld a,127
	call SCCVoice_SetLevel
	ret

; ix = this
; b = time delta
SCCVoice_UpdateRelease:
	ld a,(ix + SCCVoice_envelopeCounter)
	ld h,b
SCCVoice_UpdateRelease_Loop:
	sub (ix + SCCVoice_release)
	jr c,SCCVoice_UpdateRelease_Complete
	djnz SCCVoice_UpdateRelease_Loop
	ld b,h
	ld (ix + SCCVoice_envelopeCounter),a
	rra
	jp nz,SCCVoice_SetLevel
SCCVoice_UpdateRelease_Complete:
	ld b,h
	ld (ix + SCCVoice_envelopeCounter),0
	ld a,(SCC_mixerCopy)
	and (ix + SCCVoice_mixerAndMask)
	ld (SCC_BASE + SCC_MIXER),a
	ld (SCC_mixerCopy),a
	ret

; ix = this
; a = volume
SCCVoice_SetLevel:
	ld l,(ix + SCCVoice_velocity)
	call Math_Multiply127x127
	rrca
	rrca
	rrca
	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice_level)
	ld (hl),a
	ret

; ix = this
; hl = wave address
SCCVoice_LoadWave:
	ld e,(ix + SCCVoice_wave)
	ld d,SCC_BASE_MSB
	ld bc,32
	ldir
	ret

; ix = this
SCCVoice_Bind:
	set 7,(ix + SCCVoice_free)
	ret

; ix = this
SCCVoice_Free:
	res 7,(ix + SCCVoice_free)
	ret
