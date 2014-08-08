;
; Display an output value
;
; a = value offset
; ix = module
; iy = buffer
; hl = buffer address
; Modifies: af, bc
OutputView_Paint:
	add a,ixl
	ld c,a
	ld a,0
	adc a,ixh
	ld b,a
	call UIFocus_Paint
	ld a,(bc)
	call ValueView_Paint
	ret
