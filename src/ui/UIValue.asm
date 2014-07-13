;
; Display a signed decimal value (one’s complement)
;
UIValue: MACRO
	super: UINode UIValue_Update
	value:
		dw 0
	size:
	ENDM

	dw UIValue.size
UIValue_class: UIValue

; ix = parent
; de = y / x coordinate
; hl = value address
; ix <- instance
UIValue_New:
	push ix
	push hl
	push de
	ld iy,UIValue_class
	call Class_New
	pop de
	pop hl
	pop iy
	call UIValue_Constructor
	ret

; ix = parent
; de = y / x coordinate
; hl = value address
; de <- instance
UIValue_New_DE:
	call UIValue_New
	push iy
	ex (sp),ix
	pop de
	ret

; ix = this
; iy = parent
; de = y / x coordinate
; hl = value address
UIValue_Constructor: PROC
	ld (ix + UIValue.value),l
	ld (ix + UIValue.value + 1),h
	call UINode_SetBuffer
	ret
	ENDP

; ix = this
UIValue_Update:
	ld l,(ix + UIValue.value)
	ld h,(ix + UIValue.value + 1)
	ld a,(hl)
	ld l,(ix + UIValue.super.buffer)
	ld h,(ix + UIValue.super.buffer + 1)
	ld ix,KeyMidi_instance
	bit 0,(ix + KeyMidi.shift)
	jp nz,UIValue_FormatNumber
	jp UIValue_FormatBar

; a = number
; hl = string buffer (4 characters)
UIValue_FormatNumber: PROC
	bit 7,a
	jr nz,NegativeSign
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
UIValue_FormatBar: PROC
	add a,128
	srl a  ; covert 0-255 to 0-23
	ld b,a
	srl a
	add a,b
	srl a
	srl a
	srl a
	call WriteSegmentNoInc
	call WriteSegment
	call WriteSegment
WriteSegment:
	inc hl
WriteSegmentNoInc:
	sub 6
	jp nc,EmptySegment
	cp 256 - 6
	jp c,EmptySegment
	add a,6 + 1  ; + character offset
	ld (hl),a
	sub 6 + 1
	ret
EmptySegment:
	ld (hl),23
	ret
	ENDP
