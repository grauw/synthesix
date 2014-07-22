;
; Screen drawing buffer
;
; hl = buffer start (must be 26.5 x 80)
; de = y / x coordinate
; hl <- buffer
; Modifies: af, de
UIBuffer_GetRelativePosition:
	ld a,d  ; hl = d * 80
	ld d,0  ; de = hl + e
	add hl,de
	ex de,hl
	ld l,a
	add a,a
	add a,a
	add a,l
	add a,a
	ld l,a
	rl h
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,de
	ret

; bc = height / width
; de = destination buffer
; hl = source buffer
UIBuffer_CopyToBuffer: PROC
Loop:
	push bc
	ld a,c
	ld b,0
	ldir
	ld c,a
	ld a,80
	sub c
	jr z,NoAdd
	ld c,a
	ex de,hl
	add hl,bc
	ex de,hl
NoAdd:
	pop bc
	djnz Loop
	ret
	ENDP
