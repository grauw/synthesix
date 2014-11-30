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
	ex de,hl
	ld c,a
	ld b,0
	ld hl,ValueView_NumberLUT
	add hl,bc
	add hl,bc
	add hl,bc
	ldi
	ldi
	ldi
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
ValueView_NumberLUT:
	REPT 128, ?value
	IF ?value >= 100
	db "0" + ?value / 100
	ELSE
	db " "
	ENDIF
	IF ?value >= 10
	db "0" + ?value / 10 % 10
	ELSE
	db " "
	ENDIF
	db "0" + ?value % 10
	ENDM

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
