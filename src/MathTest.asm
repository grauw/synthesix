;
; Math unit tests
;
MathTest_Test:
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
