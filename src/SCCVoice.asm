;
; An SCC voice (channel)
;
SCCVoice: MACRO
	outputs:
	outputsEnd:
	inputs:
	note:
		dw Constants_instance + 0
	detune:
		dw Constants_instance + 0
	amplitude:
		dw Constants_instance + 0
	wave:
		dw Constants_instance + 0
	phaseReset:
		dw Constants_instance + 0
	inputsEnd:
	sccFrequency:
		dw 0
	sccAmplitude:
		db 0
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
	_size:
	ENDM

	dw SCCVoice._size
SCCVoice_class: SCCVoice

; ix, de <- new object
SCCVoice_New:
	ld iy,SCCVoice_class
	call Class_NewUpper
	jp SCCVoice_Constructor

; ix = this
; ix, de <- this
SCCVoice_Constructor:
	ld e,ixl
	ld d,ixh
	ret

; ix = this
SCCVoice_Update:
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
; SCC must be selected in page 2
SCCVoice_Apply: MACRO ?amplitude, ?frequency, ?deformation, ?wave
	ld a,(ix + SCCVoice.sccAmplitude)
	and a
	jp z,FastPath
	ex af,af'
	ld a,(ix + SCCVoice.sccDeformation)
	ld (?deformation),a
	ld de,?frequency
	call SCCVoice_ApplyFrequency
	ld de,?wave
	call SCCVoice_ApplyWave
	ex af,af'
FastPath:
	ld (?amplitude),a
	ENDM

; ix = this
; de = frequency register address
; Modifies: f, bc, de, hl
SCCVoice_ApplyFrequency: PROC
	ld c,(ix + SCCVoice.sccFrequency)
	ld b,(ix + SCCVoice.sccFrequency + 1)
	bit 5,(ix + SCCVoice.sccDeformation)
	jr nz,FrequencyChanged
	ld l,(ix + SCCVoice.lastFrequency)
	ld h,(ix + SCCVoice.lastFrequency + 1)
	and a
	sbc hl,bc
	ret z
FrequencyChanged:
	ld (ix + SCCVoice.lastFrequency),c
	ld (ix + SCCVoice.lastFrequency + 1),b
	ex de,hl
	ld (hl),0FFH
	inc l
	ld (hl),b
	dec l
	ld (hl),c
	ret
	ENDP

	SECTION ROM_BANK0

; ix = this
; de = wave register address
; Modifies: af, bc, de, hl
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

