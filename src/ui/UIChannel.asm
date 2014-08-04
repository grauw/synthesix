;
; Display a virtual keyboard
;
; iy = channel
; hl = buffer
UIChannel_Paint:
	push hl
	ex de,hl
	ld hl,UIChannel_background
	ld bc,0610H
	call UIBuffer_CopyToBuffer
	pop hl

	push hl
	ld de,010AH
	call UIBuffer_GetRelativePosition
	ld a,Channel.program
	call UIOutput_Paint
	pop hl

	push hl
	ld de,020AH
	call UIBuffer_GetRelativePosition
	ld a,Channel.channelPressure
	call UIOutput_Paint
	pop hl

	push hl
	ld de,030AH
	call UIBuffer_GetRelativePosition
	ld a,Channel.pitchBendCoarse
	call UIOutput_Paint
	pop hl

	push hl
	ld de,040AH
	call UIBuffer_GetRelativePosition
	ld a,Channel.pitchBendFine
	call UIOutput_Paint
	pop hl
	ret

;
UIChannel_background:
	db 24,23,23,23," Channel ",23,23,25
	db 22," Program 0000 ",28
	db 22," C.Press 0000 ",28
	db 22," Bend C  0000 ",28
	db 22," Bend F  0000 ",28
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,30,27
