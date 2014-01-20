;
; An SCC voice (channel)
;
SCCVoice: MACRO
	super: Voice SCCVoice_NoteOn, SCCVoice_NoteOff, SCCVoice_Update
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
	amplitude:
		dw Value_values.0
	pitch:
		dw Value_values.0
	detune:
		dw Value_values.0
	wave:
		dw Value_values.0
	noteFrequency:
		dw 0
	noteFrequency50cent:
		db 0
	frequency:
		dw 0
	lastWave:
		db -1
	free:
		db 0
	noteOnListeners: Listeners 4
	noteOffListeners: Listeners 4
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

	ld c,ixl
	ld b,ixh
	ld hl,SCCVoice.note
	add hl,bc
	ld (ix + SCCVoice.pitch),l
	ld (ix + SCCVoice.pitch + 1),h
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
; Remaining parameters are the same as Listeners_AddListener
SCCVoice_AddNoteOffListener:
	push ix
	ld bc,SCCVoice.noteOffListeners
	add ix,bc
	call Listeners_AddListener
	pop ix
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
SCCVoice_NoteOn:
	ld (ix + SCCVoice.note),b
	ld (ix + SCCVoice.velocity),c

	ld bc,SCCVoice.noteOnListeners.Update
	add ix,bc
	jp ix

; ix = this
SCCVoice_NoteOff:
	ld bc,SCCVoice.noteOffListeners.Update
	add ix,bc
	jp ix

; ix = this
SCCVoice_Update:
	ld l,(ix + SCCVoice.wave)
	ld h,(ix + SCCVoice.wave + 1)
	ld a,(hl)
	cp (ix + SCCVoice.lastWave)
	call nz,SCCVoice_SetWave

	ld l,(ix + SCCVoice.pitch)
	ld h,(ix + SCCVoice.pitch + 1)
	ld a,(hl)
	ld l,(ix + SCCVoice.detune)
	ld h,(ix + SCCVoice.detune + 1)
	ld b,(hl)
	call SCCVoice_SetFrequency

	ld l,(ix + SCCVoice.amplitude)
	ld h,(ix + SCCVoice.amplitude + 1)
	ld a,(hl)
	call SCCVoice_SetLevel
	ret

; ix = this
; a = note
; b = detune (one’s complement)
SCCVoice_SetFrequency: PROC
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
	rrca
	rrca
	rrca
	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice.levelRegister)
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
