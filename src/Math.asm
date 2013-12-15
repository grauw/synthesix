; Multiply two 7-bit numbers where one represents the range 0 .. 1.
; a = factor 1, l = factor 2
Math_Multiply7x7:
	bit 6,a
	jr z,Math_Multiply7x7_noInverse
Math_Multiply7x7_inverse:
	cpl
	rl l
	rra
	rr l
	and 00011111B
	add a,Math_multiply7x7Table / 100H
	ld h,a
	ld a,l
	and 7FH
	sub (hl)
	ret
Math_Multiply7x7_noInverse:
	rl l
	rra
	rr l
	add a,Math_multiply7x7Table / 100H
	ld h,a
	ld a,(hl)
	ret

;
; Unit tests
;

Math_UnitTest:
	ld a,0
	ld l,127
	call Math_Multiply7x7
	cp 0
	call nz,Utils_ThrowException

	ld a,127
	ld l,127
	call Math_Multiply7x7
	cp 127
	call nz,Utils_ThrowException

	ld a,47
	ld l,101
	call Math_Multiply7x7
	cp 37
	call nz,Utils_ThrowException

	ld a,101
	ld l,47
	call Math_Multiply7x7
	cp 37
	call nz,Utils_ThrowException
	ret
