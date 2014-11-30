;
; Display a horizontal scroll bar
;
; a = width
; bc = position
; de = total positions
; iy = buffer
; hl = buffer address
HorizontalScrollBarView_Paint: PROC
	bit 0,(iy + UIBuffer.repaint)
	ret z

	dec a
	push hl

	push af
	push bc
	push de
	ld (hl),140
	ld e,l
	ld d,h
	inc de
	ld c,a
	ld b,0
	call System_FastLDIR
	pop de
	pop bc
	pop af

	and a
	ld hl,0
	adc hl,de
	jr z,Done
	sbc hl,bc
	jr c,Done

	call Math_Multiply8x16
	ld c,l
	ld b,h
	call Math_Divide16

	pop hl
	push hl
	add hl,bc
	ld (hl),141
Done:
	pop hl
	ret
	ENDP
