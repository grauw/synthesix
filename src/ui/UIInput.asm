;
; Display an input value
;
; a = value offset
; iy = module
; hl = string buffer (4 characters)
; Modifies: af, bc, de
UIInput_Paint:
	ex de,hl
	add a,iyl
	ld l,a
	ld a,0
	adc a,iyh
	ld h,a
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld a,(bc)
	ex de,hl
	call UIValue_Paint
	ret
