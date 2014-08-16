;
; Display an output value
;
; a = value offset
; ix = module
; iy = buffer
; hl = buffer address
; Modifies: af, bc, de, hl
OutputView_Paint:
	add a,ixl
	ld e,a
	ld a,0
	adc a,ixh
	ld d,a
	ld a,(de)
	call ValueView_Paint
	ret
