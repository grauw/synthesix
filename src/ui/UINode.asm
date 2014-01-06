;
; Base class for all UI components
;
UINode:
UINode_update: equ $ - UINode
	dw System_ThrowException
UINode_buffer: equ $ - UINode
	dw 0

; ix = this
; iy = parent
; c = x coordinate
; b = y coordinate
; hl <- UINode_buffer = buffer
; Modifies: af, bc, de
UINode_SetBuffer:
	ld e,(iy + UINode_buffer)
	ld d,(iy + UINode_buffer + 1)
	call UINode_GetBufferPosition_DE
	ld (ix + UINode_buffer),l
	ld (ix + UINode_buffer + 1),h
	ret

; ix = this
; c = x coordinate
; b = y coordinate
; hl <- buffer
; Modifies: af, bc, de
UINode_GetBufferPosition:
	ld e,(ix + UINode_buffer)
	ld d,(ix + UINode_buffer + 1)
	call UINode_GetBufferPosition_DE
	ret

; de = buffer start (must be 26.5 x 80)
; c = x coordinate
; b = y coordinate
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
	ld l,(ix + UINode_update + 0)
	ld h,(ix + UINode_update + 1)
	jp hl

UINode_GetCoordinate
