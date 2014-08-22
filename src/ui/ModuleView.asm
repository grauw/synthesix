;
; Display a module
;
ModuleView_PORTS: equ 14

; de = module
; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_Paint:
	bit 0,(iy + UIBuffer.repaint)
	call nz,ModuleView_PaintBackground
	call ModuleView_PaintUpdate
	ret

; de = module
; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_PaintBackground:
	push de
	push hl
	call ModuleView_PaintModuleType
	pop hl
	pop de
	ret

; de = module
; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_PaintUpdate: PROC
	ld bc,UIBuffer.WIDTH * 1 + 10
	add hl,bc

	ld c,ModuleView_PORTS
	ld a,(ix + ModuleType.outputCount)
	or (ix + ModuleType.outputCount + 1)
	jr z,NoOutputs
	ld a,(ix + ModuleType.outputs)
	ld b,(ix + ModuleType.outputCount)
	push de
	push ix
	ld ixl,e
	ld ixh,d
OutputsLoop:
	push af
	push bc
	push hl
	call OutputView_Paint
	pop hl
	ld bc,UIBuffer.WIDTH
	add hl,bc
	pop bc
	pop af
	dec c
	jp z,Exit
	inc a
	djnz OutputsLoop
	pop ix
	pop de
NoOutputs:

	ld a,(ix + ModuleType.inputCount)
	or (ix + ModuleType.inputCount + 1)
	jr z,NoInputs
	ld a,(ix + ModuleType.inputs)
	ld b,(ix + ModuleType.inputCount)
	push de
	push ix
	ld ixl,e
	ld ixh,d
InputsLoop:
	push af
	push bc
	push hl
	call InputView_Paint
	pop hl
	ld bc,UIBuffer.WIDTH
	add hl,bc
	pop bc
	pop af
	dec c
	jp z,Exit
	inc a
	inc a
	djnz InputsLoop
Exit:
	pop ix
	pop de
NoInputs:
	ret
	ENDP

; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_PaintModuleType:
	ld e,(ix + ModuleType.labels)
	ld d,(ix + ModuleType.labels + 1)
	call ModuleView_PaintTop
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

; de = labels
; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_PaintPorts: PROC
	ld a,(ix + ModuleType.outputCount)
	add a,(ix + ModuleType.inputCount)
	ld c,a
	ld a,0
	ld b,ModuleView_PORTS
Loop:
	push af
	push bc
	push hl
	call ModuleView_PaintPort
	pop hl
	ld bc,UIBuffer.WIDTH
	add hl,bc
	pop bc
	pop af
	inc a
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
