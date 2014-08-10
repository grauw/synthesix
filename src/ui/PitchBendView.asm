;
; Display a pitch bend
;
; ix = pitch bend
; iy = buffer
; hl = buffer address
PitchBendView_Paint: PROC
	bit 0,(iy + UIBuffer.repaint)
	jp z,Update

	push hl
	ex de,hl
	ld hl,PitchBendView_background
	ld bc,0810H
	call UIBuffer_CopyToBuffer
	pop hl

Update:
	push hl
	ld de,010AH
	call UIBuffer_GetRelativePosition
	ld a,PitchBend.note
	call OutputView_Paint
	pop hl

	push hl
	ld de,020AH
	call UIBuffer_GetRelativePosition
	ld a,PitchBend.detune
	call OutputView_Paint
	pop hl

	push hl
	ld de,030AH
	call UIBuffer_GetRelativePosition
	ld a,PitchBend.pitchCoarse
	call InputView_Paint
	pop hl

	push hl
	ld de,040AH
	call UIBuffer_GetRelativePosition
	ld a,PitchBend.pitchFine
	call InputView_Paint
	pop hl

	push hl
	ld de,050AH
	call UIBuffer_GetRelativePosition
	ld a,PitchBend.upRange
	call InputView_Paint
	pop hl

	push hl
	ld de,060AH
	call UIBuffer_GetRelativePosition
	ld a,PitchBend.downRange
	call InputView_Paint
	pop hl
	ret
	ENDP

;
PitchBendView_background:
	db 24,23," Pitch bend ",23,25
	db 22," Note    0000 ",28
	db 22," Detune  0000 ",28
	db 29," Coarse  0000 ",22
	db 29," Fine    0000 ",22
	db 29," Range U 0000 ",22
	db 29," Range D 0000 ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
