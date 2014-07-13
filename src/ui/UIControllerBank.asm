;
; Display a virtual keyboard
;
UIControllerBank: MACRO
	super: UINode UIControllerBank_Update
	controllers:
		dw 0
	cc1:
		dw 0
	cc7:
		dw 0
	cc11:
		dw 0
	cc12:
		dw 0
	cc13:
		dw 0
	cc14:
		dw 0
	cc15:
		dw 0
	cc16:
		dw 0
	cc17:
		dw 0
	cc18:
		dw 0
	cc19:
		dw 0
	cc20:
		dw 0
	cc21:
		dw 0
	cc64:
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
	push iy
	ex (sp),ix
	pop de
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

	push hl
	push ix
	ld a,1
	call ControllerBank_GetController
	ld de,010AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc1),e
	ld (ix + UIControllerBank.cc1 + 1),d

	push hl
	push ix
	ld a,7
	call ControllerBank_GetController
	ld de,020AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc7),e
	ld (ix + UIControllerBank.cc7 + 1),d

	push hl
	push ix
	ld a,11
	call ControllerBank_GetController
	ld de,030AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc11),e
	ld (ix + UIControllerBank.cc11 + 1),d

	push hl
	push ix
	ld a,12
	call ControllerBank_GetController
	ld de,040AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc12),e
	ld (ix + UIControllerBank.cc12 + 1),d

	push hl
	push ix
	ld a,13
	call ControllerBank_GetController
	ld de,050AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc13),e
	ld (ix + UIControllerBank.cc13 + 1),d

	push hl
	push ix
	ld a,14
	call ControllerBank_GetController
	ld de,060AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc14),e
	ld (ix + UIControllerBank.cc14 + 1),d

	push hl
	push ix
	ld a,15
	call ControllerBank_GetController
	ld de,070AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc15),e
	ld (ix + UIControllerBank.cc15 + 1),d

	push hl
	push ix
	ld a,16
	call ControllerBank_GetController
	ld de,080AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc16),e
	ld (ix + UIControllerBank.cc16 + 1),d

	push hl
	push ix
	ld a,17
	call ControllerBank_GetController
	ld de,090AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc17),e
	ld (ix + UIControllerBank.cc17 + 1),d

	push hl
	push ix
	ld a,18
	call ControllerBank_GetController
	ld de,0A0AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc18),e
	ld (ix + UIControllerBank.cc18 + 1),d

	push hl
	push ix
	ld a,19
	call ControllerBank_GetController
	ld de,0B0AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc19),e
	ld (ix + UIControllerBank.cc19 + 1),d

	push hl
	push ix
	ld a,20
	call ControllerBank_GetController
	ld de,0C0AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc20),e
	ld (ix + UIControllerBank.cc20 + 1),d

	push hl
	push ix
	ld a,21
	call ControllerBank_GetController
	ld de,0D0AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc21),e
	ld (ix + UIControllerBank.cc21 + 1),d

	push hl
	push ix
	ld a,64
	call ControllerBank_GetController
	ld de,0E0AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIControllerBank.cc64),e
	ld (ix + UIControllerBank.cc64 + 1),d
	ret

; ix = this
UIControllerBank_Update:
	ld e,(ix + UIControllerBank.cc1)
	ld d,(ix + UIControllerBank.cc1 + 1)
	call UINode_Update_DE

	ld e,(ix + UIControllerBank.cc7)
	ld d,(ix + UIControllerBank.cc7 + 1)
	call UINode_Update_DE

	ld e,(ix + UIControllerBank.cc11)
	ld d,(ix + UIControllerBank.cc11 + 1)
	call UINode_Update_DE

	ld e,(ix + UIControllerBank.cc12)
	ld d,(ix + UIControllerBank.cc12 + 1)
	call UINode_Update_DE

	ld e,(ix + UIControllerBank.cc13)
	ld d,(ix + UIControllerBank.cc13 + 1)
	call UINode_Update_DE

	ld e,(ix + UIControllerBank.cc14)
	ld d,(ix + UIControllerBank.cc14 + 1)
	call UINode_Update_DE

	ld e,(ix + UIControllerBank.cc15)
	ld d,(ix + UIControllerBank.cc15 + 1)
	call UINode_Update_DE

	ld e,(ix + UIControllerBank.cc16)
	ld d,(ix + UIControllerBank.cc16 + 1)
	call UINode_Update_DE

	ld e,(ix + UIControllerBank.cc17)
	ld d,(ix + UIControllerBank.cc17 + 1)
	call UINode_Update_DE

	ld e,(ix + UIControllerBank.cc18)
	ld d,(ix + UIControllerBank.cc18 + 1)
	call UINode_Update_DE

	ld e,(ix + UIControllerBank.cc19)
	ld d,(ix + UIControllerBank.cc19 + 1)
	call UINode_Update_DE

	ld e,(ix + UIControllerBank.cc20)
	ld d,(ix + UIControllerBank.cc20 + 1)
	call UINode_Update_DE

	ld e,(ix + UIControllerBank.cc21)
	ld d,(ix + UIControllerBank.cc21 + 1)
	call UINode_Update_DE

	ld e,(ix + UIControllerBank.cc64)
	ld d,(ix + UIControllerBank.cc64 + 1)
	call UINode_Update_DE
	ret

;
UIControllerBank_background:
	db 24,23," Controllers ",25
	db 22," Mod     0000 ",22
	db 22," Volume  0000 ",22
	db 22," Express 0000 ",22
	db 22," Fx 1    0000 ",22
	db 22," Fx 2    0000 ",22
	db 22," Macro 1 0000 ",22
	db 22," Macro 2 0000 ",22
	db 22," Macro 3 0000 ",22
	db 22," Macro 4 0000 ",22
	db 22," Macro 5 0000 ",22
	db 22," Macro 6 0000 ",22
	db 22," Macro 7 0000 ",22
	db 22," Macro 8 0000 ",22
	db 22," Sustain 0000 ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
