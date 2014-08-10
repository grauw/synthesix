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
	blinkColor:
		db 0
	repaint:
		db -1
	_size:
	ENDM

	dw UIBuffer._size
UIBuffer_class: UIBuffer

; iy, de <- this
UIBuffer_New:
	ld iy,UIBuffer_class
	call Class_New
	push ix
	pop iy
	jp UIBuffer_Constructor

; iy = this
; iy, de <- this
UIBuffer_Constructor:
	ld a," "
	ld bc,UIBuffer.HEIGHT * UIBuffer.WIDTH
	ld ix,Heap_heap
	call Heap_AllocateClear
	ld (iy + UIBuffer.buffer),e
	ld (iy + UIBuffer.buffer + 1),d
	ld a,0
	ld bc,UIBuffer.HEIGHT * UIBuffer.WIDTH / 8
	ld ix,Heap_heap
	call Heap_AllocateClear
	ld (iy + UIBuffer.blinkBuffer),e
	ld (iy + UIBuffer.blinkBuffer + 1),d
	ld e,iyl
	ld d,iyh
	ret

; iy = this
; hl <- buffer
UIBuffer_GetBuffer:
	ld l,(iy + UIBuffer.buffer)
	ld h,(iy + UIBuffer.buffer + 1)
	ret

; iy = this
; hl <- blink buffer
UIBuffer_GetBlinkBuffer:
	ld l,(iy + UIBuffer.blinkBuffer)
	ld h,(iy + UIBuffer.blinkBuffer + 1)
	ret

; iy = this
; hl = buffer address
; hl <- blink buffer address
; a <- blink position
; Modifies: af, de, hl
UIBuffer_GetBlinkByBuffer:
	ld e,(iy + UIBuffer.buffer)
	ld d,(iy + UIBuffer.buffer + 1)
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
	ld e,(iy + UIBuffer.blinkBuffer)
	ld d,(iy + UIBuffer.blinkBuffer + 1)
	add hl,de
	ret

; iy = this
; de = y / x coordinate
; hl <- buffer
; Modifies: af, bc, de
UIBuffer_GetPosition:
	ld l,(iy + UIBuffer.buffer)
	ld h,(iy + UIBuffer.buffer + 1)
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

; iy = this
; hl = buffer address
; Modifies: af, de, hl
UIBuffer_SetBlinkBit:
	call UIBuffer_GetBlinkByBuffer
	ld d,UIBuffer_blinkBits >> 8
	add a,UIBuffer_blinkBits & 0FFH
	ld e,a
	ld a,(de)
	or (hl)
	ld (hl),a
	ret

; iy = this
; hl = buffer address
; Modifies: af, de, hl
UIBuffer_ResetBlinkBit:
	call UIBuffer_GetBlinkByBuffer
	ld d,UIBuffer_blinkBits >> 8
	add a,UIBuffer_blinkBits & 0FFH
	ld e,a
	ld a,(de)
	cpl
	and (hl)
	ld (hl),a
	ret

; iy = this
UIBuffer_ClearBlinkBuffer:
	ld l,(iy + UIBuffer.blinkBuffer)
	ld h,(iy + UIBuffer.blinkBuffer + 1)
	ld e,l
	ld d,h
	ld (hl),0
	inc de
	ld bc,(UIBuffer.WIDTH * UIBuffer.HEIGHT) / 8 - 1
	ldir
	ret

; iy = this
UIBuffer_Draw:
	ld a,0
	ld hl,0
	call VDP_SetWriteAddress
	ld l,(iy + UIBuffer.buffer)
	ld h,(iy + UIBuffer.buffer + 1)
	ld bc,UIBuffer.HEIGHT * UIBuffer.WIDTH
	call VDP_Write
	ld a,0
	ld hl,(TXTCOL)
	call VDP_SetWriteAddress
	ld l,(iy + UIBuffer.blinkBuffer)
	ld h,(iy + UIBuffer.blinkBuffer + 1)
	ld bc,UIBuffer.HEIGHT * UIBuffer.WIDTH / 8
	call VDP_Write
	ld a,(iy + UIBuffer.blinkColor)
	ld (VDP_MIRROR_8 + 12),a
	ld b,12
	call VDP_SetRegister
	ld (iy + UIBuffer.repaint),0
	ret

	ALIGN 8
UIBuffer_blinkBits:
	db 10000000B
	db 01000000B
	db 00100000B
	db 00010000B
	db 00001000B
	db 00000100B
	db 00000010B
	db 00000001B

