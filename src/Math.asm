; Multiply a 7-bit integer with a 7-bit number which represents the range 0..1.
; a = factor 1
; l = factor 2
; a <- product
; Modifies: hl
; Clock ticks: 77 / 98
Math_Multiply127x127:
	bit 6,a
	jr z,Math_Multiply127x127_NoInverse
Math_Multiply127x127_Inverse:
	cpl
	rl l
	rra
	rr l
	and 00011111B
	add a,Math_multiply127x127Table / 100H
	ld h,a
	ld a,l
	and 7FH
	sub (hl)
	ret
Math_Multiply127x127_NoInverse:
	rl l
	rra
	rr l
	add a,Math_multiply127x127Table / 100H
	ld h,a
	ld a,(hl)
	ret

; Multiply a 7-bit integer with a 7-bit number which represents the range 0..1.
; Implementation without lookup table. Has a miniscule rounding deviation.
; a = factor 1
; c = factor 2
; h <- product
; Clock ticks: 270 - 348
; Modifies: af, b, l
Math_Multiply127x127Alt:
	bit 6,c
	jr z,Math_Multiply127x127Alt_Cont
	inc c
Math_Multiply127x127Alt_Cont:
	add a,a
	call Math_Multiply8x8
	bit 7,l
	ret z
	inc h
	ret

; Multiply two 8-bit values
; a = factor 1
; c = factor 2
; hl <- product
; Modifies: af, b
; Clock ticks: 204 - 263
Math_Multiply8x8:
	ld b,0
	ld l,b
	add a,a
	ld h,a
	jr nc,$ + 3
	ld l,c
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
	call Math_Multiply127x127
	cp 0
	call nz,System_ThrowException

	ld a,127
	ld l,127
	call Math_Multiply127x127
	cp 127
	call nz,System_ThrowException

	ld a,47
	ld l,101
	call Math_Multiply127x127
	cp 37
	call nz,System_ThrowException

	ld a,101
	ld l,47
	call Math_Multiply127x127
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
