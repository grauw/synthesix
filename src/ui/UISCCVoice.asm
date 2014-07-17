;
; Display an SCC voice
;
UISCCVoice: MACRO
	super: UINode UISCCVoice_Update
	voice:
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
	ret

UISCCVoice_Update:
	ld e,(ix + UISCCVoice.voice)
	ld d,(ix + UISCCVoice.voice + 1)
	ld iyl,e
	ld iyh,d

	ld de,010AH
	call UINode_GetBufferPosition
	ld e,(iy + SCCVoice.note)
	ld d,(iy + SCCVoice.note + 1)
	ld a,(de)
	call UIValue_Paint

	ld de,020AH
	call UINode_GetBufferPosition
	ld e,(iy + SCCVoice.detune)
	ld d,(iy + SCCVoice.detune + 1)
	ld a,(de)
	call UIValue_Paint

	ld de,030AH
	call UINode_GetBufferPosition
	ld e,(iy + SCCVoice.amplitude)
	ld d,(iy + SCCVoice.amplitude + 1)
	ld a,(de)
	call UIValue_Paint

	ld de,040AH
	call UINode_GetBufferPosition
	ld e,(iy + SCCVoice.wave)
	ld d,(iy + SCCVoice.wave + 1)
	ld a,(de)
	call UIValue_Paint
	ret

;
UISCCVoice_background:
	db 24," SCC Voice  0 ",25
	db 29," Note    0000 ",22
	db 29," Detune  0000 ",22
	db 29," Amplitu 0000 ",22
	db 29," Wave    0000 ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
