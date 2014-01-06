;
; An SCC voice (channel)
;
	dw SCCVoice_size
SCCVoice:
SCCVoice_waveRegister: equ $ - SCCVoice
	db SCC_WAVE_1
SCCVoice_frequencyRegister: equ $ - SCCVoice
	db SCC_FREQUENCY_1
SCCVoice_levelRegister: equ $ - SCCVoice
	db SCC_LEVEL_1
SCCVoice_velocity: equ $ - SCCVoice
	db 0
SCCVoice_envelope: equ $ - SCCVoice
	dw System_ThrowException
SCCVoice_free: equ $ - SCCVoice
	db 0
SCCVoice_size: equ $ - SCCVoice

; ix = this
; b = wave register
; c = frequency register
; d = level register
; ix <- this
SCCVoice_Constructor:
	ld (ix + SCCVoice_waveRegister),b
	ld (ix + SCCVoice_frequencyRegister),c
	ld (ix + SCCVoice_levelRegister),d
	push ix
	ld iy,AREnvelope
	call Class_New
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCCVoice_envelope + 0),e
	ld (ix + SCCVoice_envelope + 1),d
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
SCCVoice_NoteOn:
	ld (ix + SCCVoice_velocity),b

	; de = frequency
	ld h,PSG_frequencyTable / 100H
	add a,a
	ld l,a
	ld e,(hl)
	inc l
	ld d,(hl)

	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice_frequencyRegister)
	ld (hl),e
	inc l
	ld (hl),d

	ld e,(ix + SCCVoice_envelope + 0)
	ld d,(ix + SCCVoice_envelope + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call AREnvelope_NoteOn
	pop ix
	call SCCVoice_SetLevel
	ret

; ix = this
SCCVoice_NoteOff:
	ld e,(ix + SCCVoice_envelope + 0)
	ld d,(ix + SCCVoice_envelope + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call AREnvelope_NoteOff
	pop ix
	call SCCVoice_SetLevel
	ret

; ix = this
; b = time delta
SCCVoice_Update:
;	ret
	ld e,(ix + SCCVoice_envelope + 0)
	ld d,(ix + SCCVoice_envelope + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call AREnvelope_Update
	pop ix
	call SCCVoice_SetLevel
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
	ld l,(ix + SCCVoice_levelRegister)
	ld (hl),a
	ret

; ix = this
; hl = wave address
SCCVoice_LoadWave:
	ld e,(ix + SCCVoice_waveRegister)
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
