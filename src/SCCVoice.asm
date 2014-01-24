;
; An SCC voice (channel)
;
SCCVoice: MACRO
	super: Voice SCCVoice_NoteOn, SCCVoice_NoteOff, SCCVoice_Update
	waveRegister:
		db SCC_WAVE_1
	frequencyRegister:
		db SCC_FREQUENCY_1
	amplitudeRegister:
		db SCC_AMPLITUDE_1
	key:
		Value 0
	velocity:
		Value 0
	trigger:
		Value 0
	gate:
		Value 0
	amplitude:
		dw Value_values.0
	note:
		dw Value_values.0
	detune:
		dw Value_values.0
	wave:
		dw Value_values.0
	lastFrequency:
		dw 0
	lastWave:
		db -1
	free:
		db 0
	noteOnListeners: Listeners 4
	size:
	ENDM

	dw SCCVoice.size
SCCVoice_class: SCCVoice

; ix = this
; b = wave register
; c = frequency register
; d = amplitude register
; ix <- this
SCCVoice_Constructor:
	ld (ix + SCCVoice.waveRegister),b
	ld (ix + SCCVoice.frequencyRegister),c
	ld (ix + SCCVoice.amplitudeRegister),d

	ld c,ixl
	ld b,ixh
	ld hl,SCCVoice.key
	add hl,bc
	ld (ix + SCCVoice.note),l
	ld (ix + SCCVoice.note + 1),h

	ld de,SCCVoice.gate - SCCVoice.key
	add hl,bc
	ld (ix + SCCVoice.amplitude),l
	ld (ix + SCCVoice.amplitude + 1),h
	ret

; ix = this
; Remaining parameters are the same as Listeners_AddListener
SCCVoice_AddNoteOnListener:
	push ix
	ld bc,SCCVoice.noteOnListeners
	add ix,bc
	call Listeners_AddListener
	pop ix
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
SCCVoice_NoteOn:
	ld (ix + SCCVoice.key),b
	ld (ix + SCCVoice.velocity),c
	ld (ix + SCCVoice.trigger),7FH
	ld (ix + SCCVoice.gate),7FH

	ld bc,SCCVoice.noteOnListeners.Update
	add ix,bc
	jp ix

; ix = this
SCCVoice_NoteOff:
	ld (ix + SCCVoice.gate),0
	ret

; ix = this
SCCVoice_Update:
	ld (ix + SCCVoice.trigger),0

	ld l,(ix + SCCVoice.amplitude)
	ld h,(ix + SCCVoice.amplitude + 1)
	ld a,(hl)
	and a
;	jp z,SCCVoice_SetAmplitude
	push af

	ld l,(ix + SCCVoice.wave)
	ld h,(ix + SCCVoice.wave + 1)
	ld a,(hl)
	cp (ix + SCCVoice.lastWave)
	call nz,SCCVoice_SetWave

	ld l,(ix + SCCVoice.note)
	ld h,(ix + SCCVoice.note + 1)
	ld a,(hl)
	ld l,(ix + SCCVoice.detune)
	ld h,(ix + SCCVoice.detune + 1)
	ld b,(hl)
	call SCCVoice_SetPitch

	pop af
	call SCCVoice_SetAmplitude
	ret

; ix = this
; a = note
; b = detune (one’s complement)
SCCVoice_SetPitch: PROC
	ld h,PSG_frequencyTable / 100H
	add a,a
	ld l,a
	ld e,(hl)
	inc l
	ld d,(hl)
	bit 7,b
	jr nz,Negative
	inc l     ; get 100 cent upwards
	ld a,e
	sub (hl)
	inc a     ; round up division that follows
	jp Continue
Negative:
	dec l     ; get 100 cent downwards
	dec l
	dec l
	ld a,(hl)
	sub e
Continue:
	srl a     ; divide 100 cent to 50 cent
	ld l,b
	call Math_Multiply127x127Signed
	cpl
	call Math_AddSigned
	ld a,(ix + SCCVoice.lastFrequency)
	cp e
	jr nz,FrequencyChanged
	ld a,(ix + SCCVoice.lastFrequency + 1)
	cp d
	ret z
FrequencyChanged:
	ld (ix + SCCVoice.lastFrequency),e
	ld (ix + SCCVoice.lastFrequency + 1),d
	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice.frequencyRegister)
	ld (hl),e
	inc l
	ld (hl),d
	ret
	ENDP

; ix = this
; a = amplitude (one’s complement)
SCCVoice_SetAmplitude:
	and 7FH
	rrca
	rrca
	rrca
	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice.amplitudeRegister)
	ld (hl),a
	ret

; ix = this
; a = wave number (one’s complement)
; Modifies: af, bc, de, hl
SCCVoice_SetWave:
	ld (ix + SCCVoice.lastWave),a
	add a,a
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,SCCWaveTable_table1
	add hl,bc
	ld a,ROM_WaveTableBank
	ld (ROM_BANK_3_CHANGE),a
	ld e,(ix + SCCVoice.waveRegister)
	ld d,SCC_BASE_MSB
	REPT 32
	ldi
	ENDM
	ld a,ROM_Bank3Default
	ld (ROM_BANK_3_CHANGE),a
	ret
