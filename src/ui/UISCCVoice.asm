;
; Display an SCC voice
;
UISCCVoice: MACRO
	super: UINode UISCCVoice_Update
	size:
	ENDM

; ix = this
UISCCVoice_Constructor:
	ret

; ix = this
UISCCVoice_Update:
	ret

; iy = voice
; hl = buffer
UISCCVoice_Paint:
	push hl
	ex de,hl
	ld hl,UISCCVoice_background
	ld bc,0610H
	call UINode_CopyToBuffer_DE
	pop hl

	push hl
	ld de,000DH
	call UINode_GetRelativePosition
	call SCCVoice_GetNumber_IY
	add a,"1"
	ld (hl),a
	pop hl

	push hl
	ld de,010AH
	call UINode_GetRelativePosition
	ld e,(iy + SCCVoice.note)
	ld d,(iy + SCCVoice.note + 1)
	ld a,(de)
	call UIValue_Paint
	pop hl

	push hl
	ld de,020AH
	call UINode_GetRelativePosition
	ld e,(iy + SCCVoice.detune)
	ld d,(iy + SCCVoice.detune + 1)
	ld a,(de)
	call UIValue_Paint
	pop hl

	push hl
	ld de,030AH
	call UINode_GetRelativePosition
	ld e,(iy + SCCVoice.amplitude)
	ld d,(iy + SCCVoice.amplitude + 1)
	ld a,(de)
	call UIValue_Paint
	pop hl

	push hl
	ld de,040AH
	call UINode_GetRelativePosition
	ld e,(iy + SCCVoice.wave)
	ld d,(iy + SCCVoice.wave + 1)
	ld a,(de)
	call UIValue_Paint
	pop hl
	ret

;
UISCCVoice_background:
	db 24," SCC Voice  0 ",25
	db 29," Note    0000 ",22
	db 29," Detune  0000 ",22
	db 29," Amplitu 0000 ",22
	db 29," Wave    0000 ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
