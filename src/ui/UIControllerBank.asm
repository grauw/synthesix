;
; Display a virtual keyboard
;
UIControllerBank: MACRO
	super: UINode UIControllerBank_Update
	controllers:
		dw 0
	size:
	ENDM

	dw UIControllerBank.size
UIControllerBank_class: UIControllerBank

; ix = parent
; de = y / x coordinate
; hl = controller bank
; ix <- instance
UIControllerBank_New:
	push ix
	push hl
	push de
	ld iy,UIControllerBank_class
	call Class_New
	pop de
	pop hl
	pop iy
	call UIControllerBank_Constructor
	ret

; ix = parent
; de = y / x coordinate
; hl = controller bank
; de <- instance
UIControllerBank_New_DE:
	call UIControllerBank_New
	ld e,ixl
	ld d,ixh
	ret

; ix = this
; hl = controller bank
UIControllerBank_Constructor:
	ld (ix + UIControllerBank.controllers),l
	ld (ix + UIControllerBank.controllers + 1),h
	push hl
	call UINode_SetBuffer
	pop hl

	push hl
	ld hl,UIControllerBank_background
	ld de,0000H
	ld bc,1010H
	call UINode_CopyToBuffer
	pop hl
	ret

; ix = this
UIControllerBank_Update:
	ld e,(ix + UIControllerBank.controllers)
	ld d,(ix + UIControllerBank.controllers + 1)
	ld iyl,e
	ld iyh,d

	ld de,010AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.1)
	call UIValue_Paint

	ld de,020AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.7)
	call UIValue_Paint

	ld de,030AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.11)
	call UIValue_Paint

	ld de,040AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.12)
	call UIValue_Paint

	ld de,050AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.13)
	call UIValue_Paint

	ld de,060AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.14)
	call UIValue_Paint

	ld de,070AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.15)
	call UIValue_Paint

	ld de,080AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.16)
	call UIValue_Paint

	ld de,090AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.17)
	call UIValue_Paint

	ld de,0A0AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.18)
	call UIValue_Paint

	ld de,0B0AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.19)
	call UIValue_Paint

	ld de,0C0AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.20)
	call UIValue_Paint

	ld de,0D0AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.21)
	call UIValue_Paint

	ld de,0E0AH
	call UINode_GetBufferPosition
	ld a,(iy + ControllerBank.controllers.64)
	call UIValue_Paint
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
