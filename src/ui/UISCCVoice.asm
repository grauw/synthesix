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
; de = x / y coordinate
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
; de = x / y coordinate
; hl = value address
; de <- instance
UISCCVoice_New_DE:
	call UISCCVoice_New
	push iy
	ex (sp),ix
	pop de
	ret

; ix = this
; hl = voice
UISCCVoice_Constructor:
	ld (ix + UISCCVoice.voice),l
	ld (ix + UISCCVoice.voice + 1),h
	push hl
	call UINode_SetBuffer
	pop iy

	push ix
	push iy
	ld bc,UISCCVoice_width << 8 | UISCCVoice_height
	ld de,0000H
	ld hl,UISCCVoice_template
	call UIPanel_New
	pop iy
	pop ix

	ld de,0014H
	call UINode_GetBufferPosition
	call SCCVoice_GetNumber_IY
	add a,"1"
	ld (hl),a

	push ix
	push iy
	ld l,(iy + SCCVoice.amplitude)
	ld h,(iy + SCCVoice.amplitude + 1)
	ld de,0219H
	call UIValue_New_DE
	ld (ix + UISCCVoice.amplitudeValue),e
	ld (ix + UISCCVoice.amplitudeValue + 1),d
	pop iy
	pop ix

	push ix
	push iy
	ld l,(iy + SCCVoice.note)
	ld h,(iy + SCCVoice.note + 1)
	ld de,0108H
	call UIValue_New_DE
	ld (ix + UISCCVoice.noteValue),e
	ld (ix + UISCCVoice.noteValue + 1),d
	pop iy
	pop ix

	push ix
	push iy
	ld l,(iy + SCCVoice.detune)
	ld h,(iy + SCCVoice.detune + 1)
	ld de,0119H
	call UIValue_New_DE
	ld (ix + UISCCVoice.detuneValue),e
	ld (ix + UISCCVoice.detuneValue + 1),d
	pop iy
	pop ix

	push ix
	push iy
	ld l,(iy + SCCVoice.wave)
	ld h,(iy + SCCVoice.wave + 1)
	ld de,0208H
	call UIValue_New_DE
	ld (ix + UISCCVoice.waveValue),e
	ld (ix + UISCCVoice.waveValue + 1),d
	pop iy
	pop ix
	ret

UISCCVoice_Update:
	ld e,(ix + UISCCVoice.amplitudeValue)
	ld d,(ix + UISCCVoice.amplitudeValue + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call UINode_Update
	pop ix

	ld e,(ix + UISCCVoice.noteValue)
	ld d,(ix + UISCCVoice.noteValue + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call UINode_Update
	pop ix

	ld e,(ix + UISCCVoice.detuneValue)
	ld d,(ix + UISCCVoice.detuneValue + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call UINode_Update
	pop ix

	ld e,(ix + UISCCVoice.waveValue)
	ld d,(ix + UISCCVoice.waveValue + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call UINode_Update
	pop ix
	ret

;
UISCCVoice_width: equ 31
UISCCVoice_height: equ 4
UISCCVoice_template:
	db 24,23,23,23,23,23,23,23,23," SCC Voice 0 ",23,23,23,23,23,23,23,23,25
	db 22," Note: 0000     Detune: 0000 ",22
	db 22," Wave: 0000  Amplitude: 0000 ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
