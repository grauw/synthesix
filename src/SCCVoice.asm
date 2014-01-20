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
	amplitude:
		dw Value_values.0
	pitch:
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
	ld (ix + SCCVoice.velocity),c

	ld a,b
	call SCCVoice_SetNote

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
	ld l,(ix + SCCVoice.wave + 0)
	ld h,(ix + SCCVoice.wave + 1)
	ld a,(hl)
	cp (ix + SCCVoice.lastWave)
	call nz,SCCVoice_SetWave

	ld l,(ix + SCCVoice.pitch + 0)
	ld h,(ix + SCCVoice.pitch + 1)
	ld a,(hl)
	call SCCVoice_SetFrequency

	ld l,(ix + SCCVoice.amplitude + 0)
	ld h,(ix + SCCVoice.amplitude + 1)
	ld a,(hl)
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
