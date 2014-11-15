;
; Display a module
;
ModuleView_WIDTH: equ 16

; b = number of ports to show
; c = first port
; de = module
; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_Paint:
	ld a,(ix + ModuleType.outputCount)
	add a,(ix + ModuleType.inputCount)
	dec a
	cp c
	call c,System_ThrowException  ; scroll position exceeds port count
	bit 0,(iy + UIBuffer.repaint)
	call nz,ModuleView_PaintBackground
	call ModuleView_PaintUpdate
	ret

; b = number of ports to show
; c = first port
; de = module
; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_PaintBackground:
	push bc
	push de
	push hl
	call ModuleView_PaintModuleType
	pop hl
	pop de
	pop bc
	ret

; b = number of ports to show
; c = first port
; de = module
; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_PaintUpdate: PROC
	push bc
	ld bc,UIBuffer.WIDTH * 1 + 10
	add hl,bc
	pop bc
	ld a,(ix + ModuleType.outputCount)
	add a,(ix + ModuleType.inputCount)
Loop:
	push af
	push bc
	push de
	push hl
	ld a,c
	call ModuleView_PaintUpdatePort
	pop hl
	pop de
	ld bc,UIBuffer.WIDTH
	add hl,bc
	pop bc
	pop af
	inc c
	cp c
	ret z
	djnz Loop
	ret
	ENDP

; a = port
; de = module
; ix = module type
; iy = buffer
; hl = buffer address
; Modifies: af, bc, de, hl
ModuleView_PaintUpdatePort: PROC
	bit 0,(ix + ModuleType.outputCount + 1)
	jr nz,Output
	ld b,(ix + ModuleType.outputCount)
	sub b
	jr nc,Input
	add a,b
Output:
	add a,(ix + ModuleType.outputs)
	push hl
	ld l,a
	ld h,0
	add hl,de
	ld a,(hl)
	pop hl
	jp ValueView_Paint
Input:
	add a,a
	add a,(ix + ModuleType.inputs)
	push hl
	ld l,a
	ld h,0
	add hl,de
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	ld a,(hl)
	pop hl
	jp ValueView_Paint
	ENDP

; b = number of ports to show
; c = first port
; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_PaintModuleType:
	push bc
	ld e,(ix + ModuleType.labels)
	ld d,(ix + ModuleType.labels + 1)
	call ModuleView_PaintTop
	pop bc
	call ModuleView_PaintPorts
	call ModuleView_PaintBottom
	ret

; de = labels
; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_PaintTop: PROC
	push de
	push hl
	ex de,hl
	ld hl,ModuleView_top
	ld bc,16
	ldir
	pop hl
	pop de
	push hl
	push hl
	call ModuleView_GetStringLength
	ex (sp),hl
	cp 13
	jr c,NotTooLong
	ld a,12
	ld c,-12
NotTooLong:
	sra c
	adc hl,bc
	ld bc,7
	add hl,bc
	ld c,a
	ld (hl)," "
	inc hl
	ex de,hl
	ldir
	ex de,hl
	ld (hl)," "
	pop de
	pop hl
	ld bc,UIBuffer.WIDTH
	add hl,bc
	ret
	ENDP

; de = labels
; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_PaintBottom:
	push de
	push hl
	ex de,hl
	ld hl,ModuleView_bottom
	ld bc,0110H
	call UIBuffer_CopyToBuffer
	pop hl
	pop de
	ret

; b = number of ports to show
; c = first port
; de = labels
; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_PaintPorts: PROC
	push bc
	ld a,c
	call ModuleView_GetPortLabel
	pop bc
	ld a,(ix + ModuleType.outputCount)
	add a,(ix + ModuleType.inputCount)
Loop:
	push af
	push bc
	push hl
	ld a,c
	call ModuleView_PaintPort
	pop hl
	ld bc,UIBuffer.WIDTH
	add hl,bc
	pop bc
	pop af
	inc c
	cp c
	ret z
	djnz Loop
	ret
	ENDP

; a = port
; de = labels
; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_PaintPort: PROC
	push de
	push hl
	ex de,hl
	call ModuleView_GetPortBackground
	call UIBuffer_CopyToBuffer
	pop hl
	pop de
	inc hl
	inc hl
	ld b,7
Loop:
	ld a,(de)
	inc de
	and a
	ret z
	ld (hl),a
	inc hl
	djnz Loop
Loop2:
	ld a,(de)
	inc de
	and a
	jp nz,Loop2
	ret
	ENDP

; a = port
; bc <- port background size
; hl <- port background
ModuleView_GetPortBackground:
	ld bc,0110H
	ld hl,ModuleView_output
	bit 0,(ix + ModuleType.outputCount + 1)
	ret nz
	cp (ix + ModuleType.outputCount)
	ret c
	ld hl,ModuleView_input
	ret

; a = port
; de = labels
; de <- port label
; Modifies: af, bc, de
ModuleView_GetPortLabel: PROC
	and a
	ret z
	ex de,hl
	ld b,a
	xor a
Loop:
	ld c,0FFH
	cpir
	call po,System_ThrowException
	djnz Loop
	ex de,hl
	ret
	ENDP

; de = ASCIIZ string
; a <- length, excluding the terminator
; bc <- 0 - length, excluding the terminator
; hl <- end of ASCIIZ string + 1
; Modifies: af, bc, hl
ModuleView_GetStringLength:
	ex de,hl
	ld e,l
	ld d,h
	xor a
	ld b,a
	ld c,a
	cpir
	ld a,c
	inc bc
	cpl
	ret

;
ModuleView_top:
	db 24,23,23,23,23,23,23,23,23,23,23,23,23,23,23,25

ModuleView_bottom:
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27

ModuleView_output:
	db 22,"         ---- ",28

ModuleView_input:
	db 29,"         ---- ",22
