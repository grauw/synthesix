;
; Display a virtual keyboard
;
; iy = note
; hl = buffer
UINote_Paint:
	push hl
	ex de,hl
	ld hl,UINote_background
	ld bc,0610H
	call UIBuffer_CopyToBuffer
	pop hl

	push hl
	ld de,010AH
	call UIBuffer_GetRelativePosition
	ld a,Note.key
	call UIOutput_Paint
	pop hl

	push hl
	ld de,020AH
	call UIBuffer_GetRelativePosition
	ld a,Note.velocity
	call UIOutput_Paint
	pop hl

	push hl
	ld de,030AH
	call UIBuffer_GetRelativePosition
	ld a,Note.trigger
	call UIOutput_Paint
	pop hl

	push hl
	ld de,040AH
	call UIBuffer_GetRelativePosition
	ld a,Note.gate
	call UIOutput_Paint
	pop hl
	ret

;
UINote_background:
	db 24,23,23,23,23," Note ",23,23,23,23,25
	db 22," Key     0000 ",28
	db 22," Velocit 0000 ",28
	db 22," Trigger 0000 ",28
	db 22," Gate    0000 ",28
	db 26,23,23,23,23,23,23,23,23,23,23,23,30,31,31,27
