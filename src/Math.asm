; Add the signed value A to DE.
; a = value (one’s complement)
; de = value
; de <- value + product
; Modifies: af
Math_AddSigned: PROC
	and a
	jp m,Subtract
	add a,e
	ld e,a
	ret nc
	inc d
	ret
Subtract:
	inc e
	add a,e
	ld e,a
	ret c
	dec d
	ret
	ENDP

	SECTION ROM_BANK0

; Multiply a 7-bit integer with a 7-bit number which represents the range 0..1.
; Bit 7 of a must be 0, bit 7 of l is ignored.
; a = multiplicand
; l = multiplier
; a <- product
; Modifies: hl
; Clock ticks: 132
Math_Multiply127x127: PROC
	rl l
	rra
	rr l
	bit 5,a
	jp nz,Bank2
	add a,Math_multiply127x127Table / 100H
	ld h,ROM_BANK_6000_CHANGE / 100H
	di
	ld (hl),ROM_MultiplyTableBank1
	ld h,a
	ld a,(hl)
	ld hl,(ROM_bank6000)
	ei
	ld (hl),l
	ret
Bank2:
	add a,Math_multiply127x127Table / 100H - (1 << 5)  ; cancel out bit 5
	ld h,ROM_BANK_6000_CHANGE / 100H
	di
	ld (hl),ROM_MultiplyTableBank2
	ld h,a
	ld a,(hl)
	ld hl,(ROM_bank6000)
	ei
	ld (hl),l
	ret
	ENDP

	ENDS

; Multiply an 8-bit signed integer with a 8-bit signed fractional number which
; represents the range 0..1.
; a = multiplicand (one’s complement)
; l = multiplier
; a <- product (one’s complement)
; Modifies: hl
Math_Multiply127x127Signed: PROC
	bit 7,l
	jr nz,NegativeAddend
	and a
	jp p,Math_Multiply127x127
	cpl
	call Math_Multiply127x127
	cpl
	ret
NegativeAddend:
	and a
	jp m,NegativeAugend
	ld h,l
	ld l,a
	ld a,h
	cpl
	call Math_Multiply127x127
	cpl
	ret
NegativeAugend:
	cpl
	ld h,l
	ld l,a
	ld a,h
	cpl
	jp Math_Multiply127x127
	ret
	ENDP

; Parameters identical to Math_Multiply127x127
; Clock ticks: 228
Math_Multiply127x127Alt:
	ld h,a
	srl a
	REPT 7
	rr l
	jr nc,Next
	add a,h
Next:
	rra
	ENDM
	adc a,0
	ret

; Multiply a 7-bit integer with a 7-bit number which represents the range 0..1.
; Implementation without lookup table. Has a miniscule rounding deviation.
; Note: Value range is suitable for use of David Heremans’ multiplication code.
;       http://www.mccw.hetlab.tk/92/Multiplication/en.html (has 512 byte table)
;       Clock ticks go down to 155 / 165, and factor 2 can passed in b/c/d/e.
; a = factor 1
; c = factor 2
; h <- product
; Clock ticks: 270 - 348
; Modifies: af, b, l
Math_Multiply127x127Alt2: PROC
	bit 6,c
	jr z,Continue
	inc c
Continue:
	add a,a
	call Math_Multiply8x8
	bit 7,l
	ret z
	inc h
	ret
	ENDP

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

	ld a,47
	ld l,101
	call Math_Multiply127x127Signed
	cp 37
	call nz,System_ThrowException

	ld a,~47
	ld l,101
	call Math_Multiply127x127Signed
	cp ~37
	call nz,System_ThrowException

	ld a,47
	ld l,~101
	call Math_Multiply127x127Signed
	cp ~37
	call nz,System_ThrowException

	ld a,~47
	ld l,~101
	call Math_Multiply127x127Signed
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
