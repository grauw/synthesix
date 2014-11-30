;
; Display a signed decimal value (one’s complement)
;
; a = value
; hl = string buffer (4 characters)
ValueView_Paint:
	push hl
	ld hl,KeyMidi_instance.caps
	bit 0,(hl)
	pop hl
	jp nz,ValueView_FormatNumber
	jp ValueView_FormatBar

; a = number
; hl = string buffer (4 characters)
ValueView_FormatNumber: PROC
	and a
	jp m,NegativeSign
	ld (hl)," "
	jp ContinueSign
NegativeSign:
	ld (hl),"-"
	cpl
ContinueSign:
	inc hl
	sub 100
	jp c,NoDigit100
	ld (hl),"1"
	jp Continue100
NoDigit100:
	ld (hl)," "
	add a,100
	cp 10
	jp nc,Continue100
	inc hl
	ld (hl)," "
	jp Continue10
Continue100:
	inc hl
	ld b,-1
Loop10:
	inc b
	sub 10
	jp nc,Loop10
	add a,10
	push af
	ld a,b
	add a,"0"
	ld (hl),a
	pop af
Continue10:
	inc hl
	add a,"0"
	ld (hl),a
	ret
	ENDP

; a = number
; hl = string buffer (4 characters)
ValueView_FormatBar: PROC
	srl a  ; covert 0-255 to 0-23 * 4
	ld b,a
	srl a
	add a,b
	and 11111000B
	rrca
	ex de,hl
	ld c,a
	ld b,0
	ld hl,ValueView_barLUT
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	ret
	ENDP

;
ValueView_barLUT:
	db 23,23,1,23
	db 23,23,2,23
	db 23,23,3,23
	db 23,23,4,23
	db 23,23,5,23
	db 23,23,6,23
	db 23,23,23,1
	db 23,23,23,2
	db 23,23,23,3
	db 23,23,23,4
	db 23,23,23,5
	db 23,23,23,6
	db 1,23,23,23
	db 2,23,23,23
	db 3,23,23,23
	db 4,23,23,23
	db 5,23,23,23
	db 6,23,23,23
	db 23,1,23,23
	db 23,2,23,23
	db 23,3,23,23
	db 23,4,23,23
	db 23,5,23,23
	db 23,6,23,23
