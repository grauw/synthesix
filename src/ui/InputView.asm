;
; Display an input value
;
; a = value offset
; ix = module
; iy = buffer
; hl = buffer address
; Modifies: af, bc, de, hl
InputView_Paint:
	add a,ixl
	ld e,a
	ld a,0
	adc a,ixh
	ld d,a
	call UIFocus_Paint
	ex de,hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	ex de,hl
	ld a,(bc)
	call ValueView_Paint
	ret
