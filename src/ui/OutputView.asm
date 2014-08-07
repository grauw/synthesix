;
; Display an output value
;
; c = value offset
; iy = module
; hl = string buffer (4 characters)
; Modifies: af, bc
OutputView_Paint:
	add a,iyl
	ld c,a
	ld a,0
	adc a,iyh
	ld b,a
	call UIFocus_Paint
	ld a,(bc)
	call ValueView_Paint
	ret
