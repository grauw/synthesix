;
; Display an AR envelope
;
; ix = AR envelope
; iy = buffer
; hl = buffer address
EnvelopeARView_Paint: PROC
	bit 0,(iy + UIBuffer.repaint)
	jp z,Update

	push hl
	ex de,hl
	ld hl,EnvelopeARView_background
	ld bc,0710H
	call UIBuffer_CopyToBuffer
	pop hl

Update:
	push hl
	ld de,010AH
	call UIBuffer_GetRelativePosition
	ld a,EnvelopeAR.value
	call OutputView_Paint
	pop hl

	push hl
	ld de,020AH
	call UIBuffer_GetRelativePosition
	ld a,EnvelopeAR.attack
	call InputView_Paint
	pop hl

	push hl
	ld de,030AH
	call UIBuffer_GetRelativePosition
	ld a,EnvelopeAR.release
	call InputView_Paint
	pop hl

	push hl
	ld de,040AH
	call UIBuffer_GetRelativePosition
	ld a,EnvelopeAR.gate
	call InputView_Paint
	pop hl

	push hl
	ld de,050AH
	call UIBuffer_GetRelativePosition
	ld a,EnvelopeAR.trigger
	call InputView_Paint
	pop hl
	ret
	ENDP

;
EnvelopeARView_background:
	db 24,23," AR envelope ",25
	db 22," Value   0000 ",28
	db 29," Attack  0000 ",22
	db 29," Release 0000 ",22
	db 29," Gate    0000 ",22
	db 29," Trigger 0000 ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
