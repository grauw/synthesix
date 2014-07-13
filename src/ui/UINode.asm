;
; Base class for all UI components
;
UINode: MACRO ?update
	update:
		dw ?update
	buffer:
		dw 0
	ENDM

; ix = this
; iy = parent
; de = x / y coordinate
; hl <- UINode.buffer = buffer
; Modifies: af, bc, de
UINode_SetBuffer:
	ld c,(iy + UINode.buffer)
	ld b,(iy + UINode.buffer + 1)
	call UINode_GetBufferPosition_BC
	ld (ix + UINode.buffer),l
	ld (ix + UINode.buffer + 1),h
	ret

; ix = this
; de = x / y coordinate
; hl <- buffer
; Modifies: af, bc, de
UINode_GetBufferPosition:
	ld c,(ix + UINode.buffer)
	ld b,(ix + UINode.buffer + 1)
	call UINode_GetBufferPosition_BC
	ret

; bc = buffer start (must be 26.5 x 80)
; de = x / y coordinate
; hl <- buffer
; Modifies: af, de
UINode_GetBufferPosition_BC:
	ld a,d  ; hl = d * 80
	add a,a
	add a,a
	add a,d
	add a,a
	ld l,a
	ld h,0
	rl h
	add hl,hl
	add hl,hl
	add hl,hl
	ld d,0
	add hl,de
	add hl,bc
	ret

; ix = this
; iy = parent
; bc = width / height
; de = x / y coordinate
; hl = source buffer
UINode_CopyToBuffer: PROC
	push bc
	push hl
	call UINode_GetBufferPosition
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

; ix = this
UINode_Update:
	ld l,(ix + UINode.update)
	ld h,(ix + UINode.update + 1)
	jp hl

; de = this
UINode_Update_DE:
	push ix
	ld ixl,e
	ld ixh,d
	call UINode_Update
	pop ix
	ret
