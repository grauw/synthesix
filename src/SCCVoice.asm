;
; An SCC voice (channel)
;
SCCVoice: MACRO
	slot:
		db 0
	preparedSlot:
		ds 4
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
	sccAmplitude:
		db 0
	sccFrequency:
		dw 0
	sccDeformation:
		db 0
	sccWave:
		db 0
	sccWaveAddress:
		dw 0
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

; a = slot
; b = wave register
; c = frequency register
; d = amplitude register
; ix, de <- new object
SCCVoice_New:
	push af
	push bc
	push de
	ld iy,SCCVoice_class
	call Class_NewUpper
	pop de
	pop bc
	pop af
	jp SCCVoice_Constructor

; ix = this
; a = slot
; b = wave register
; c = frequency register
; d = amplitude register
; ix, de <- this
SCCVoice_Constructor:
	ld (ix + SCCVoice.slot),a
	ld (ix + SCCVoice.waveRegister),b
	ld (ix + SCCVoice.frequencyRegister),c
	ld (ix + SCCVoice.amplitudeRegister),d

	call Memory_PrepareSlotPage2
	ld (ix + SCCVoice.preparedSlot),b
	ld (ix + SCCVoice.preparedSlot + 1),c
	ld (ix + SCCVoice.preparedSlot + 2),d
	ld (ix + SCCVoice.preparedSlot + 3),e

	ld e,ixl
	ld d,ixh
	ret

; ix = this
SCCVoice_Update:
	call SCCVoice_Prepare
	call SCCVoice_Apply
	ret

SCCVoice_Prepare:
	call SCCVoice_PrepareAmplitude
	ret z  ; the fast path
	call SCCVoice_PrepareFrequency
	call SCCVoice_PrepareDeformation
	call SCCVoice_PrepareWave
	ret

; ix = this
; a = amplitude (one’s complement)
; f <- z: amplitude zero
SCCVoice_PrepareAmplitude:
	ld l,(ix + SCCVoice.amplitude)
	ld h,(ix + SCCVoice.amplitude + 1)
	ld a,(hl)
	rrca
	rrca
	rrca
	and 0FH
	ld (ix + SCCVoice.sccAmplitude),a
	ret

; ix = this
SCCVoice_PrepareFrequency: PROC
	ld l,(ix + SCCVoice.note)
	ld h,(ix + SCCVoice.note + 1)
	ld a,(hl)
	ld l,(ix + SCCVoice.detune)
	ld h,(ix + SCCVoice.detune + 1)
	ld b,(hl)
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
	ld (ix + SCCVoice.sccFrequency),e
	ld (ix + SCCVoice.sccFrequency + 1),d
	ret
	ENDP

; ix = this
SCCVoice_PrepareDeformation:
	ld l,(ix + SCCVoice.phaseReset)
	ld h,(ix + SCCVoice.phaseReset + 1)
	ld a,(hl)
	and 1 << 6
	rrca
	ld (ix + SCCVoice.sccDeformation),a
	ret

; ix = this
; a = wave number (one’s complement)
; Modifies: af, bc, de, hl
SCCVoice_PrepareWave:
	ld l,(ix + SCCVoice.wave)
	ld h,(ix + SCCVoice.wave + 1)
	ld a,(hl)
	ld (ix + SCCVoice.sccWave),a
	ret

; ix = this
SCCVoice_Apply: PROC
	ld b,(ix + SCCVoice.preparedSlot)
	ld c,(ix + SCCVoice.preparedSlot + 1)
	ld d,(ix + SCCVoice.preparedSlot + 2)
	ld e,(ix + SCCVoice.preparedSlot + 3)
	call Memory_SetPreparedSlotPage2
	exx
	ld a,(ix + SCCVoice.sccAmplitude)
	and a
	jp z,FastPath
	ex af,af'
	ld a,(ix + SCCVoice.sccDeformation)
	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice.deformationRegister)
	ld (hl),a
	call SCCVoice_ApplyFrequency
	call SCCVoice_ApplyWave
	ex af,af'
FastPath:
	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice.amplitudeRegister)
	ld (hl),a
	exx
	call Memory_SetPreparedSlotPage2
	ret
	ENDP

; ix = this
SCCVoice_ApplyFrequency: PROC
	ld e,(ix + SCCVoice.sccFrequency)
	ld d,(ix + SCCVoice.sccFrequency + 1)
	bit 5,(ix + SCCVoice.sccDeformation)
	jr nz,FrequencyChanged
	ld l,(ix + SCCVoice.lastFrequency)
	ld h,(ix + SCCVoice.lastFrequency + 1)
	and a
	sbc hl,de
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
	ENDP

	SECTION ROM_BANK0

; ix = this
SCCVoice_ApplyWave:
	ld a,(ix + SCCVoice.sccWave)
	cp (ix + SCCVoice.lastWave)
	ret z
	ld (ix + SCCVoice.lastWave),a
	ld h,ROM_BANK_6000_CHANGE / 100H
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
	ld hl,(ROM_bank6000)
	ld (hl),l
	ret

	ENDS

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

