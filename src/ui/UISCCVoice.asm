;
; Display an SCC voice
;
UISCCVoice: MACRO
	super: UINode UISCCVoice_Update
	voice:
		dw 0
	amplitudeValue:
		dw 0
	noteValue:
		dw 0
	detuneValue:
		dw 0
	waveValue:
		dw 0
	size:
	ENDM

	dw UISCCVoice.size
UISCCVoice_class: UISCCVoice

; ix = parent
; de = y / x coordinate
; hl = voice
; ix <- instance
UISCCVoice_New:
	push ix
	push hl
	push de
	ld iy,UISCCVoice_class
	call Class_New
	pop de
	pop hl
	pop iy
	call UISCCVoice_Constructor
	ret

; ix = parent
; de = y / x coordinate
; hl = voice
; de <- instance
UISCCVoice_New_DE:
	call UISCCVoice_New
	ld e,ixl
	ld d,ixh
	ret

; ix = this
; hl = voice
UISCCVoice_Constructor:
	ld (ix + UISCCVoice.voice),l
	ld (ix + UISCCVoice.voice + 1),h
	push hl
	call UINode_SetBuffer
	pop iy

	ld hl,UISCCVoice_background
	ld de,0000H
	ld bc,0610H
	call UINode_CopyToBuffer

	ld de,000DH
	call UINode_GetBufferPosition
	call SCCVoice_GetNumber_IY
	add a,"1"
	ld (hl),a

	push ix
	push iy
	ld l,(iy + SCCVoice.amplitude)
	ld h,(iy + SCCVoice.amplitude + 1)
	ld de,030AH
	call UIValue_New_DE
	pop iy
	pop ix
	ld (ix + UISCCVoice.amplitudeValue),e
	ld (ix + UISCCVoice.amplitudeValue + 1),d

	push ix
	push iy
	ld l,(iy + SCCVoice.note)
	ld h,(iy + SCCVoice.note + 1)
	ld de,010AH
	call UIValue_New_DE
	pop iy
	pop ix
	ld (ix + UISCCVoice.noteValue),e
	ld (ix + UISCCVoice.noteValue + 1),d

	push ix
	push iy
	ld l,(iy + SCCVoice.detune)
	ld h,(iy + SCCVoice.detune + 1)
	ld de,020AH
	call UIValue_New_DE
	pop iy
	pop ix
	ld (ix + UISCCVoice.detuneValue),e
	ld (ix + UISCCVoice.detuneValue + 1),d

	push ix
	push iy
	ld l,(iy + SCCVoice.wave)
	ld h,(iy + SCCVoice.wave + 1)
	ld de,040AH
	call UIValue_New_DE
	pop iy
	pop ix
	ld (ix + UISCCVoice.waveValue),e
	ld (ix + UISCCVoice.waveValue + 1),d
	ret

UISCCVoice_Update:
	ld e,(ix + UISCCVoice.amplitudeValue)
	ld d,(ix + UISCCVoice.amplitudeValue + 1)
	call UINode_Update_DE

	ld e,(ix + UISCCVoice.noteValue)
	ld d,(ix + UISCCVoice.noteValue + 1)
	call UINode_Update_DE

	ld e,(ix + UISCCVoice.detuneValue)
	ld d,(ix + UISCCVoice.detuneValue + 1)
	call UINode_Update_DE

	ld e,(ix + UISCCVoice.waveValue)
	ld d,(ix + UISCCVoice.waveValue + 1)
	call UINode_Update_DE
	ret

;
UISCCVoice_background:
	db 24," SCC Voice  0 ",25
	db 22," Note    0000 ",22
	db 22," Detune  0000 ",22
	db 22," Amplitu 0000 ",22
	db 22," Wave    0000 ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
