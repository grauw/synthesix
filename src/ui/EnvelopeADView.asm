;
; Display an AD envelope
;
; ix = AD envelope
; iy = buffer
; hl = buffer address
EnvelopeADView_Paint: PROC
	bit 0,(iy + UIBuffer.repaint)
	jp z,Update

	push hl
	ex de,hl
	ld hl,EnvelopeADView_background
	ld bc,0610H
	call UIBuffer_CopyToBuffer
	pop hl

Update:
	push hl
	ld de,010AH
	call UIBuffer_GetRelativePosition
	ld a,EnvelopeAD.value
	call OutputView_Paint
	pop hl

	push hl
	ld de,020AH
	call UIBuffer_GetRelativePosition
	ld a,EnvelopeAD.attack
	call InputView_Paint
	pop hl

	push hl
	ld de,030AH
	call UIBuffer_GetRelativePosition
	ld a,EnvelopeAD.decay
	call InputView_Paint
	pop hl

	push hl
	ld de,040AH
	call UIBuffer_GetRelativePosition
	ld a,EnvelopeAD.trigger
	call InputView_Paint
	pop hl
	ret
	ENDP

;
EnvelopeADView_background:
	db 24,23," AR envelope ",25
	db 22," Value   0000 ",28
	db 29," Attack  0000 ",22
	db 29," Decay   0000 ",22
	db 29," Trigger 0000 ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
