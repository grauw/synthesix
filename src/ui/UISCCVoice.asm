;
; Display an SCC voice
;
; iy = voice
; hl = buffer
UISCCVoice_Paint:
	push hl
	ex de,hl
	ld hl,UISCCVoice_background
	ld bc,0610H
	call UIBuffer_CopyToBuffer
	pop hl

	push hl
	ld de,000DH
	call UIBuffer_GetRelativePosition
	call SCCVoice_GetNumber_IY
	add a,"1"
	ld (hl),a
	pop hl

	push hl
	ld de,010AH
	call UIBuffer_GetRelativePosition
	ld a,SCCVoice.note
	call UIInput_Paint
	pop hl

	push hl
	ld de,020AH
	call UIBuffer_GetRelativePosition
	ld a,SCCVoice.detune
	call UIInput_Paint
	pop hl

	push hl
	ld de,030AH
	call UIBuffer_GetRelativePosition
	ld a,SCCVoice.amplitude
	call UIInput_Paint
	pop hl

	push hl
	ld de,040AH
	call UIBuffer_GetRelativePosition
	ld a,SCCVoice.wave
	call UIInput_Paint
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
