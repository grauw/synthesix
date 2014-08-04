;
; Display a virtual keyboard
;
; iy = controller bank
; hl = buffer
UIControllerBank_Paint:
	push hl
	ex de,hl
	ld hl,UIControllerBank_background
	ld bc,1010H
	call UIBuffer_CopyToBuffer
	pop hl

	push hl
	ld de,010AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.1
	call UIOutput_Paint
	pop hl

	push hl
	ld de,020AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.7
	call UIOutput_Paint
	pop hl

	push hl
	ld de,030AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.11
	call UIOutput_Paint
	pop hl

	push hl
	ld de,040AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.12
	call UIOutput_Paint
	pop hl

	push hl
	ld de,050AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.13
	call UIOutput_Paint
	pop hl

	push hl
	ld de,060AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.16
	call UIOutput_Paint
	pop hl

	push hl
	ld de,070AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.17
	call UIOutput_Paint
	pop hl

	push hl
	ld de,080AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.18
	call UIOutput_Paint
	pop hl

	push hl
	ld de,090AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.19
	call UIOutput_Paint
	pop hl

	push hl
	ld de,0A0AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.80
	call UIOutput_Paint
	pop hl

	push hl
	ld de,0B0AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.81
	call UIOutput_Paint
	pop hl

	push hl
	ld de,0C0AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.82
	call UIOutput_Paint
	pop hl

	push hl
	ld de,0D0AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.83
	call UIOutput_Paint
	pop hl

	push hl
	ld de,0E0AH
	call UIBuffer_GetRelativePosition
	ld a,ControllerBank.controllers.64
	call UIOutput_Paint
	pop hl
	ret

;
UIControllerBank_background:
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
