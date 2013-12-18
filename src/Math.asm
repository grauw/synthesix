; Multiply two 7-bit numbers where one represents the range 0 .. 1.
; a = factor 1
; l = factor 2
; a <- product
; Clock ticks: 77 / 98
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

; Multiply two 8-bit values
; a = factor 1
; c = factor 2
; hl <- product
; Modifies: af, b
; Clock ticks: 204 - 270
Math_Multiply8x8:
	ld b,0
	ld l,b
	add a,a
	ld h,a
	jr nc,$ + 3
	add hl,bc
	REPT 6
	add hl,hl
	jr nc,$ + 3
	add hl,bc
	ENDM
	add hl,hl
	ret nc
	add hl,bc
	ret

; Multiply an 8-bit value with a 16-bit value
; a = factor 1
; bc = factor 2
; hl <- product
; Modifies: af, hl
; Clock ticks: 235 - 301
Math_Multiply8x16:
	ld l,0
	add a,a
	jr nc,$ + 3
	add hl,bc
	REPT 6
	add hl,hl
	add a,a
	jr nc,$ + 3
	add hl,bc
	ENDM
	add hl,hl
	add a,a
	ret nc
	add hl,bc
	ret

;
; Unit tests
;
Math_UnitTest:
	ld a,0
	ld l,127
	call Math_Multiply7x7
	cp 0
	call nz,System_ThrowException

	ld a,127
	ld l,127
	call Math_Multiply7x7
	cp 127
	call nz,System_ThrowException

	ld a,47
	ld l,101
	call Math_Multiply7x7
	cp 37
	call nz,System_ThrowException

	ld a,101
	ld l,47
	call Math_Multiply7x7
	cp 37
	call nz,System_ThrowException

	ld a,101
	ld c,150
	call Math_Multiply8x8
	and a
	ld bc,15150
	sbc hl,bc
	call nz,System_ThrowException

	ld a,10
	ld bc,5555
	call Math_Multiply8x16
	and a
	ld bc,55550
	sbc hl,bc
	call nz,System_ThrowException
	ret
