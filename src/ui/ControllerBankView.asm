;
; Display a controller bank
;
; ix = controller bank
; iy = buffer
; hl = buffer address
ControllerBankView_Paint: PROC
	bit 0,(iy + UIBuffer.repaint)
	jp z,Update

	push hl
	ex de,hl
	ld hl,ControllerBankView_background
	ld bc,1010H
	call UIBuffer_CopyToBuffer
	pop hl

Update:
	push hl
	ld de,010AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.1
	call OutputView_Paint
	pop hl

	push hl
	ld de,020AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.7
	call OutputView_Paint
	pop hl

	push hl
	ld de,030AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.11
	call OutputView_Paint
	pop hl

	push hl
	ld de,040AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.12
	call OutputView_Paint
	pop hl

	push hl
	ld de,050AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.13
	call OutputView_Paint
	pop hl

	push hl
	ld de,060AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.16
	call OutputView_Paint
	pop hl

	push hl
	ld de,070AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.17
	call OutputView_Paint
	pop hl

	push hl
	ld de,080AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.18
	call OutputView_Paint
	pop hl

	push hl
	ld de,090AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.19
	call OutputView_Paint
	pop hl

	push hl
	ld de,0A0AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.80
	call OutputView_Paint
	pop hl

	push hl
	ld de,0B0AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.81
	call OutputView_Paint
	pop hl

	push hl
	ld de,0C0AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.82
	call OutputView_Paint
	pop hl

	push hl
	ld de,0D0AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.83
	call OutputView_Paint
	pop hl

	push hl
	ld de,0E0AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.64
	call OutputView_Paint
	pop hl
	ret
	ENDP

;
ControllerBankView_background:
	db 24,23," Controllers ",25
	db 22," Mod     0000 ",28
	db 22," Volume  0000 ",28
	db 22," Express 0000 ",28
	db 22," Fx 1    0000 ",28
	db 22," Fx 2    0000 ",28
	db 22," Macro 1 0000 ",28
	db 22," Macro 2 0000 ",28
	db 22," Macro 3 0000 ",28
	db 22," Macro 4 0000 ",28
	db 22," Macro 5 0000 ",28
	db 22," Macro 6 0000 ",28
	db 22," Macro 7 0000 ",28
	db 22," Macro 8 0000 ",28
	db 22," Sustain 0000 ",28
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
