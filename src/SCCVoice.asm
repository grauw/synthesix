;
; An SCC voice (channel)
;
SCCVoice: MACRO
	waveRegister:
		db SCC_WAVE_1
	frequencyRegister:
		db SCC_FREQUENCY_1
	amplitudeRegister:
		db SCC_AMPLITUDE_1
	deformationRegister:
		db SCC_DEFORMATION
	amplitude:
		dw Value_values.0
	note:
		dw Value_values.0
	detune:
		dw Value_values.0
	wave:
		dw Value_values.0
	phaseReset:
		dw Value_values.0
	lastFrequency:
		dw 0
	lastWave:
		db -1
	free:
		db 0
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
	ret

; ix = this
SCCVoice_Update:
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
	ld l,(ix + SCCVoice.phaseReset)
	ld h,(ix + SCCVoice.phaseReset + 1)
	bit 6,(hl)
	jr nz,PhaseReset
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
	ld (hl),0FFH
	inc l
	ld (hl),d
	dec l
	ld (hl),e
	ret
PhaseReset:
	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice.deformationRegister)
	ld (hl),00100000B
	push hl
	call FrequencyChanged
	pop hl
	ld (hl),0
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
	ld h,ROM_BANK_3_CHANGE / 100H
	ld (hl),ROM_WaveTableBank
	add a,a
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,SCCWaveTable_table1
	add hl,bc
	ld e,(ix + SCCVoice.waveRegister)
	ld d,SCC_BASE_MSB
	REPT 32
	ldi
	ENDM
	ld hl,(ROM_page3)
	ld (hl),l
	ret

; ix = this
; a <- voice number (0 .. 4)
SCCVoice_GetNumber:
	ld a,(ix + SCCVoice.amplitudeRegister)
	sub SCC_AMPLITUDE_1
	ret

; ix = this
; a <- voice number (0 .. 4)
SCCVoice_GetNumber_IY:
	ld a,(iy + SCCVoice.amplitudeRegister)
	sub SCC_AMPLITUDE_1
	ret

; ix = this
; f <- nz: bound
SCCVoice_IsBound:
	bit 7,(ix + SCCVoice.free)
	ret

; ix = this
SCCVoice_Bind:
	set 7,(ix + SCCVoice.free)
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,SCCVoice_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
SCCVoice_Release:
	res 7,(ix + SCCVoice.free)
	ret

