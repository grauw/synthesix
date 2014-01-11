;
; An SCC voice (channel)
;
SCCVoice: MACRO
	waveRegister:
		db SCC_WAVE_1
	frequencyRegister:
		db SCC_FREQUENCY_1
	levelRegister:
		db SCC_LEVEL_1
	note:
		db 0
	velocity:
		db 0
	modulation:
		dw System_ThrowException
	pitchModulation:
		dw System_ThrowException
	free:
		db 0
	size:
	ENDM

	dw SCCVoice.size
SCCVoice_class: SCCVoice

; ix = this
; b = wave register
; c = frequency register
; d = level register
; ix <- this
SCCVoice_Constructor:
	ld (ix + SCCVoice.waveRegister),b
	ld (ix + SCCVoice.frequencyRegister),c
	ld (ix + SCCVoice.levelRegister),d
	push ix
	ld iy,AREnvelope_class
	call Class_New
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCCVoice.modulation + 0),e
	ld (ix + SCCVoice.modulation + 1),d
	push ix
	ld iy,TriangleLFO_class
	call Class_New
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCCVoice.pitchModulation + 0),e
	ld (ix + SCCVoice.pitchModulation + 1),d
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
SCCVoice_NoteOn:
	ld (ix + SCCVoice.note),b
	ld (ix + SCCVoice.velocity),c

	ld e,(ix + SCCVoice.pitchModulation + 0)
	ld d,(ix + SCCVoice.pitchModulation + 1)
	ld iyl,e
	ld iyh,d
	call Modulation_NoteOn
	ld b,a
	ld a,(ix + SCCVoice.note)
	call SCCVoice_SetNote

	ld e,(ix + SCCVoice.modulation + 0)
	ld d,(ix + SCCVoice.modulation + 1)
	ld iyl,e
	ld iyh,d
	call Modulation_NoteOn
	call SCCVoice_SetLevel
	ret

; ix = this
SCCVoice_NoteOff:
	ld e,(ix + SCCVoice.pitchModulation + 0)
	ld d,(ix + SCCVoice.pitchModulation + 1)
	ld iyl,e
	ld iyh,d
	call Modulation_NoteOff
	ld b,a
	ld a,(ix + SCCVoice.note)
	call SCCVoice_SetNote

	ld e,(ix + SCCVoice.modulation + 0)
	ld d,(ix + SCCVoice.modulation + 1)
	ld iyl,e
	ld iyh,d
	call Modulation_NoteOff
	call SCCVoice_SetLevel
	ret

; ix = this
SCCVoice_Update:
	ld e,(ix + SCCVoice.pitchModulation + 0)
	ld d,(ix + SCCVoice.pitchModulation + 1)
	ld iyl,e
	ld iyh,d
	call Modulation_Update
	ld b,a
	ld a,(ix + SCCVoice.note)
	call SCCVoice_SetNote

	ld e,(ix + SCCVoice.modulation + 0)
	ld d,(ix + SCCVoice.modulation + 1)
	ld iyl,e
	ld iyh,d
	call Modulation_Update
	call SCCVoice_SetLevel
	ret

; ix = this
; a = note
; b = detune
SCCVoice_SetNote:
	ld h,PSG_frequencyTable / 100H
	add a,a
	ld l,a
	ld e,(hl)
	inc l
	ld d,(hl)
	inc l
	ld a,(hl)
	sub e
	neg
	srl a
	ld l,b
	call Math_Multiply127x127
	add a,e
	ld e,a
	ld a,d
	adc a,0
	ld d,a
	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice.frequencyRegister)
	ld (hl),e
	inc l
	ld (hl),d
	ret

; ix = this
; a = level
SCCVoice_SetLevel:
	ld l,(ix + SCCVoice.velocity)
	call Math_Multiply127x127
	rrca
	rrca
	rrca
	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice.levelRegister)
	ld (hl),a
	ret

; ix = this
; hl = wave address
SCCVoice_SetWave:
	ld e,(ix + SCCVoice.waveRegister)
	ld d,SCC_BASE_MSB
	ld bc,32
	ldir
	ret
