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
	call UINode_CopyToBuffer_DE
	pop hl

	push hl
	ld de,010AH
	call UINode_GetRelativePosition
	ld a,(iy + Note.key)
	call UIValue_Paint
	pop hl

	push hl
	ld de,020AH
	call UINode_GetRelativePosition
	ld a,(iy + Note.velocity)
	call UIValue_Paint
	pop hl

	push hl
	ld de,030AH
	call UINode_GetRelativePosition
	ld a,(iy + Note.trigger)
	call UIValue_Paint
	pop hl

	push hl
	ld de,040AH
	call UINode_GetRelativePosition
	ld a,(iy + Note.gate)
	call UIValue_Paint
	pop hl
	ret

;
UINote_background:
	db 24,23,23,23,23," Note ",23,23,23,23,25
	db 22," Key     0000 ",28
	db 22," Velocit 0000 ",28
	db 22," Trigger 0000 ",28
	db 22," Gate    0000 ",28
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
