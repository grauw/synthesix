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
; de = y / x coordinate
; hl <- UINode.buffer = buffer
; Modifies: af, de
UINode_SetBuffer:
	ld l,(iy + UINode.buffer)
	ld h,(iy + UINode.buffer + 1)
	call UINode_GetRelativePosition
	ld (ix + UINode.buffer),l
	ld (ix + UINode.buffer + 1),h
	ret

; ix = this
; hl <- buffer
UINode_GetBuffer:
	ld l,(ix + UINode.buffer)
	ld h,(ix + UINode.buffer + 1)
	ret

; ix = this
; de = y / x coordinate
; hl <- buffer
; Modifies: af, de
UINode_GetBufferPosition:
	ld l,(ix + UINode.buffer)
	ld h,(ix + UINode.buffer + 1)
	call UINode_GetRelativePosition
	ret

; hl = buffer start (must be 26.5 x 80)
; de = y / x coordinate
; hl <- buffer
; Modifies: af, de
UINode_GetRelativePosition:
	ld a,d  ; hl = d * 80
	ld d,0  ; de = hl + e
	add hl,de
	ex de,hl
	ld l,a
	add a,a
	add a,a
	add a,l
	add a,a
	ld l,a
	rl h
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,de
	ret

; ix = this
; bc = height / width
; de = y / x coordinate
; hl = source buffer
UINode_CopyToBuffer: PROC
	push hl
	call UINode_GetBufferPosition
	ex de,hl
	pop hl
Loop:
	push bc
	ld a,c
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
	djnz Loop
	ret
	ENDP

; bc = height / width
; de = destination buffer
; hl = source buffer
UINode_CopyToBuffer_DE: equ UINode_CopyToBuffer.Loop

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
