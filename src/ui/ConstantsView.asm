;
; Display the constants
;
; ix = constants
; iy = buffer
; hl = buffer address
ConstantsView_Paint: PROC
	bit 0,(iy + UIBuffer.repaint)
	jp z,Update

	push hl
	ex de,hl
	ld hl,ConstantsView_background
	ld bc,1010H
	call UIBuffer_CopyToBuffer
	pop hl

Update:
	push hl
	ld de,010AH
	call UIBuffer_GetRelativePosition
	ld a,0
	call OutputView_Paint
	pop hl

	push hl
	ld de,020AH
	call UIBuffer_GetRelativePosition
	ld a,1
	call OutputView_Paint
	pop hl

	push hl
	ld de,030AH
	call UIBuffer_GetRelativePosition
	ld a,2
	call OutputView_Paint
	pop hl

	push hl
	ld de,040AH
	call UIBuffer_GetRelativePosition
	ld a,3
	call OutputView_Paint
	pop hl

	push hl
	ld de,050AH
	call UIBuffer_GetRelativePosition
	ld a,4
	call OutputView_Paint
	pop hl

	push hl
	ld de,060AH
	call UIBuffer_GetRelativePosition
	ld a,5
	call OutputView_Paint
	pop hl

	push hl
	ld de,070AH
	call UIBuffer_GetRelativePosition
	ld a,6
	call OutputView_Paint
	pop hl

	push hl
	ld de,080AH
	call UIBuffer_GetRelativePosition
	ld a,7
	call OutputView_Paint
	pop hl

	push hl
	ld de,090AH
	call UIBuffer_GetRelativePosition
	ld a,8
	call OutputView_Paint
	pop hl

	push hl
	ld de,0A0AH
	call UIBuffer_GetRelativePosition
	ld a,9
	call OutputView_Paint
	pop hl

	push hl
	ld de,0B0AH
	call UIBuffer_GetRelativePosition
	ld a,10
	call OutputView_Paint
	pop hl

	push hl
	ld de,0C0AH
	call UIBuffer_GetRelativePosition
	ld a,11
	call OutputView_Paint
	pop hl

	push hl
	ld de,0D0AH
	call UIBuffer_GetRelativePosition
	ld a,12
	call OutputView_Paint
	pop hl

	push hl
	ld de,0E0AH
	call UIBuffer_GetRelativePosition
	ld a,13
	call OutputView_Paint
	pop hl
	ret
	ENDP

;
ConstantsView_background:
	db 24,23,23," Constants ",23,25
	db 22," 0       0000 ",28
	db 22," 1       0000 ",28
	db 22," 2       0000 ",28
	db 22," 3       0000 ",28
	db 22," 4       0000 ",28
	db 22," 5       0000 ",28
	db 22," 6       0000 ",28
	db 22," 7       0000 ",28
	db 22," 8       0000 ",28
	db 22," 9       0000 ",28
	db 22," 10      0000 ",28
	db 22," 11      0000 ",28
	db 22," 12      0000 ",28
	db 22," 13      0000 ",28
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
