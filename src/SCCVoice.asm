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
	noteFrequency:
		dw 0
	noteFrequency50cent:
		db 0
	frequency:
		dw 0
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
	call AREnvelope_New
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCCVoice.modulation + 0),e
	ld (ix + SCCVoice.modulation + 1),d
	push ix
	call TriangleLFO_New
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
	ld (ix + SCCVoice.velocity),c

	ld a,b
	call SCCVoice_SetNote

	ld e,(ix + SCCVoice.pitchModulation + 0)
	ld d,(ix + SCCVoice.pitchModulation + 1)
	ld iyl,e
	ld iyh,d
	call Modulation_NoteOn

	ld e,(ix + SCCVoice.modulation + 0)
	ld d,(ix + SCCVoice.modulation + 1)
	ld iyl,e
	ld iyh,d
	call Modulation_NoteOn
	ret

; ix = this
SCCVoice_NoteOff:
	ld e,(ix + SCCVoice.pitchModulation + 0)
	ld d,(ix + SCCVoice.pitchModulation + 1)
	ld iyl,e
	ld iyh,d
	call Modulation_NoteOff

	ld e,(ix + SCCVoice.modulation + 0)
	ld d,(ix + SCCVoice.modulation + 1)
	ld iyl,e
	ld iyh,d
	call Modulation_NoteOff
	ret

; ix = this
SCCVoice_Update:
	ld e,(ix + SCCVoice.pitchModulation + 0)
	ld d,(ix + SCCVoice.pitchModulation + 1)
	ld iyl,e
	ld iyh,d
	call Modulation_Update
	call SCCVoice_SetFrequency

	ld e,(ix + SCCVoice.modulation + 0)
	ld d,(ix + SCCVoice.modulation + 1)
	ld iyl,e
	ld iyh,d
	call Modulation_Update
	call SCCVoice_SetLevel
	ret

; ix = this
; a = note
SCCVoice_SetNote: PROC
	ld (ix + SCCVoice.note),a
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
	ld (ix + SCCVoice.noteFrequency),e
	ld (ix + SCCVoice.noteFrequency + 1),d
	ld (ix + SCCVoice.noteFrequency50cent),a
	ret
	ENDP

; ix = this
; a = detune (one’s complement)
SCCVoice_SetFrequency: PROC
	ld e,(ix + SCCVoice.noteFrequency)
	ld d,(ix + SCCVoice.noteFrequency + 1)
	ld l,(ix + SCCVoice.noteFrequency50cent)
	call Math_Multiply127x127Signed
	cpl
	call Math_AddSigned
	ld a,(ix + SCCVoice.frequency)
	cp e
	jr nz,FrequencyChanged
	ld a,(ix + SCCVoice.frequency + 1)
	cp d
	ret z
FrequencyChanged:
	ld (ix + SCCVoice.frequency),e
	ld (ix + SCCVoice.frequency + 1),d
	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice.frequencyRegister)
	ld (hl),e
	inc l
	ld (hl),d
	ret
	ENDP

; ix = this
; a = level (one’s complement)
SCCVoice_SetLevel:
	and 7FH
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
