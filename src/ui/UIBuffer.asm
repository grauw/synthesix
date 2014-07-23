;
; Screen drawing buffer
;
UIBuffer: MACRO
	WIDTH: equ 80
	HEIGHT: equ 27
	buffer:
		dw 0
	blinkBuffer:
		dw 0
	size:
	ENDM

	dw UIBuffer.size
UIBuffer_class: UIBuffer

; ix <- this
UIBuffer_New:
	push af
	push bc
	push de
	ld iy,UIBuffer_class
	call Class_New
	pop de
	pop bc
	pop af
	jp UIBuffer_Constructor

; ix = this
UIBuffer_Constructor:
	ld bc,UIBuffer.HEIGHT * UIBuffer.WIDTH
	push ix
	ld ix,Heap_heap
	call Heap_Allocate
	pop ix
	ld (ix + UIBuffer.buffer),e
	ld (ix + UIBuffer.buffer + 1),d
	ld l,e
	ld h,d
	ld (hl)," "
	inc de
	dec bc
	ldir
	ld bc,UIBuffer.HEIGHT * UIBuffer.WIDTH / 8
	push ix
	ld ix,Heap_heap
	call Heap_Allocate
	pop ix
	ld (ix + UIBuffer.blinkBuffer),e
	ld (ix + UIBuffer.blinkBuffer + 1),d
	ld l,e
	ld h,d
	ld (hl),0
	inc de
	dec bc
	ldir
	ret

; hl <- buffer
UIBuffer_GetBuffer:
	ld l,(ix + UIBuffer.buffer)
	ld h,(ix + UIBuffer.buffer + 1)
	ret

; hl <- blink buffer
UIBuffer_GetBlinkBuffer:
	ld l,(ix + UIBuffer.blinkBuffer)
	ld h,(ix + UIBuffer.blinkBuffer + 1)
	ret

; hl = buffer address
; hl <- blink buffer address
; a <- blink position
UIBuffer_GetBlinkByBuffer:
	ld e,(ix + UIBuffer.buffer)
	ld d,(ix + UIBuffer.buffer + 1)
	xor a
	sbc hl,de
	rr h
	rr l
	rra
	rr h
	rr l
	rra
	rr h
	rr l
	rra
	rlca
	rlca
	rlca
	ld e,(ix + UIBuffer.blinkBuffer)
	ld d,(ix + UIBuffer.blinkBuffer + 1)
	add hl,de
	ret

; ix = this
; de = y / x coordinate
; hl <- buffer
; Modifies: af, bc, de
UIBuffer_GetPosition:
	ld l,(ix + UIBuffer.buffer)
	ld h,(ix + UIBuffer.buffer + 1)
	call UIBuffer_GetRelativePosition
	ret

; hl = current buffer position
; de = y / x coordinate
; hl <- buffer
; Modifies: af, de
UIBuffer_GetRelativePosition:
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

; bc = height / width
; de = destination buffer
; hl = source buffer
UIBuffer_CopyToBuffer: PROC
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

; ix = this
UIBuffer_Draw:
	ld a,0
	ld hl,0
	call VDP_SetWriteAddress
	ld l,(ix + UIBuffer.buffer)
	ld h,(ix + UIBuffer.buffer + 1)
	ld bc,UIBuffer.HEIGHT * UIBuffer.WIDTH
	call VDP_Write
	ld a,0
	ld hl,(TXTCOL)
	call VDP_SetWriteAddress
	ld l,(ix + UIBuffer.blinkBuffer)
	ld h,(ix + UIBuffer.blinkBuffer + 1)
	ld bc,UIBuffer.HEIGHT * UIBuffer.WIDTH / 8
	call VDP_Write
	ret
