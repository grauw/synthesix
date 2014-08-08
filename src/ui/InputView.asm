;
; Display an input value
;
; a = value offset
; ix = module
; iy = buffer
; hl = buffer address
; Modifies: af, bc, de
InputView_Paint:
	ex de,hl
	add a,ixl
	ld l,a
	ld a,0
	adc a,ixh
	ld h,a
	ld c,(hl)
	inc hl
	ld b,(hl)
	ex de,hl
	call UIFocus_Paint
	ld a,(bc)
	call ValueView_Paint
	ret
