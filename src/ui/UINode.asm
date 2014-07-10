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
; bc = x / y coordinate
; hl <- UINode.buffer = buffer
; Modifies: af, bc, de
UINode_SetBuffer:
	ld e,(iy + UINode.buffer)
	ld d,(iy + UINode.buffer + 1)
	call UINode_GetBufferPosition_DE
	ld (ix + UINode.buffer),l
	ld (ix + UINode.buffer + 1),h
	ret

; ix = this
; bc = x / y coordinate
; hl <- buffer
; Modifies: af, bc, de
UINode_GetBufferPosition:
	ld e,(ix + UINode.buffer)
	ld d,(ix + UINode.buffer + 1)
	call UINode_GetBufferPosition_DE
	ret

; de = buffer start (must be 26.5 x 80)
; bc = x / y coordinate
; hl <- buffer
; Modifies: af, bc, de
UINode_GetBufferPosition_DE:
	ld a,b  ; hl = b * 80
	add a,a
	add a,a
	add a,b
	add a,a
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	ld b,0
	add hl,bc
	add hl,de
	ret

; ix = this
UINode_Update:
	ld l,(ix + UINode.update)
	ld h,(ix + UINode.update + 1)
	jp hl

UINode_GetCoordinate
