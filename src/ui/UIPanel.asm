;
; A buffered panel
;
UIPanel: MACRO
	super:
		UINode UIPanel_Update
	size:
	ENDM

	dw UIPanel.size
UIPanel_class: UIPanel

; ix = parent
; c = x coordinate
; b = y coordinate
; d = width
; e = height
; hl = source buffer
; ix <- instance
UIPanel_New:
	push bc
	push de
	push hl
	push ix
	ld iy,UIPanel_class
	call Class_New
	pop iy
	pop hl
	pop de
	pop bc
	call UIPanel_Constructor
	ret

; ix = parent
; c = x coordinate
; b = y coordinate
; d = width
; e = height
; hl = source buffer
; de <- instance
UIPanel_New_DE:
	call UIPanel_New
	push iy
	ex (sp),ix
	pop de
	ret

; ix = this
; iy = parent
; c = x coordinate
; b = y coordinate
; d = width
; e = height
; hl = source buffer
UIPanel_Constructor: PROC
	push de
	push hl
	call UINode_SetBuffer
	ex de,hl
	pop hl
	pop bc
Loop:
	push bc
	ld a,b
	ld c,a
	ld b,0
	ldir
	ld c,a
	ld a,80
	sub c
	jr z,NoAdd
	ld c,a
	ex de,hl
	add hl,bc
	ex de,hl
NoAdd:
	pop bc
	dec c
	jp nz,Loop
	ret
	ENDP

UIPanel_Update:
	ret
