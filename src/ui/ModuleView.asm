;
; Display a module
;
; de = module
; ix = module type
; iy = buffer
; hl = buffer address
ModuleView_Paint: PROC
	bit 0,(iy + UIBuffer.repaint)
	jp z,Update

	push de
	push hl
	call ModuleView_PaintModuleType
	pop hl
	pop de

Update:
	ld bc,UIBuffer.WIDTH * 1 + 10
	add hl,bc

	ld c,14
	ld a,(ix + ModuleType.outputCount)
	or (ix + ModuleType.outputCount + 1)
	jr z,NoOutputs
	ld a,(ix + ModuleType.outputs)
	ld b,(ix + ModuleType.outputCount)
	push de
	push ix
	push de
	pop ix
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
	ret z
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
	push de
	pop ix
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
	ret z
	inc a
	inc a
	djnz InputsLoop
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
	call ModuleView_PaintOutputs
	call ModuleView_PaintInputs
	call ModuleView_PaintBottom
	ret

;
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

ModuleView_PaintOutputs: PROC
	bit 0,(ix + ModuleType.outputCount + 1)
	jr nz,Limit
	ld a,(ix + ModuleType.outputCount)
	cp 14
	jr c,Loop
Limit:
	ld a,14
Loop:
	and a
	ret z
	push af
	call ModuleView_PaintOutput
	pop af
	ld bc,UIBuffer.WIDTH
	add hl,bc
	dec a
	jp Loop
	ENDP

ModuleView_PaintOutput: PROC
	push de
	push hl
	ex de,hl
	ld hl,ModuleView_output
	ld bc,0110H
	call UIBuffer_CopyToBuffer
	pop hl
	pop de
	push hl
	inc hl
	inc hl
	ld b,7
Loop:
	ld a,(de)
	inc de
	and a
	jp z,Done
	ld (hl),a
	inc hl
	djnz Loop
Loop2:
	ld a,(de)
	inc de
	and a
	jp nz,Loop2
Done:
	pop hl
	ret
	ENDP

ModuleView_PaintInputs: PROC
	bit 0,(ix + ModuleType.inputCount + 1)
	jr nz,Limit
	ld a,(ix + ModuleType.inputCount)
	cp 14
	jr c,Loop
Limit:
	ld a,14
Loop:
	and a
	ret z
	push af
	call ModuleView_PaintInput
	pop af
	ld bc,UIBuffer.WIDTH
	add hl,bc
	dec a
	jp Loop
	ENDP

ModuleView_PaintInput: PROC
	push de
	push hl
	ex de,hl
	ld hl,ModuleView_input
	ld bc,0110H
	call UIBuffer_CopyToBuffer
	pop hl
	pop de
	push hl
	inc hl
	inc hl
	ld b,7
Loop:
	ld a,(de)
	inc de
	and a
	jp z,Done
	ld (hl),a
	inc hl
	djnz Loop
Loop2:
	ld a,(de)
	inc de
	and a
	jp nz,Loop2
Done:
	pop hl
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
