;
; A pitch bend
;
PitchBend: MACRO
	note:
		Value 0
	detune:
		Value 0
	pitchCoarse:
		dw 0
	pitchFine:
		dw 0
	upRange:    ;max range is 31 notes
		db 2
	downRange:  ;max range is 31 notes
		db 2
	size:
	ENDM

	dw PitchBend.size
PitchBend_class: PitchBend

; ix <- new class
PitchBend_New:
	ld iy,PitchBend_class
	call Class_New
	call PitchBend_Constructor
	ret

; ix = this
PitchBend_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,PitchBend_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
PitchBend_Update: PROC
	ld l,(ix + PitchBend.pitchFine)
	ld h,(ix + PitchBend.pitchFine + 1)
	ld e,(hl)
	ld l,(ix + PitchBend.pitchCoarse)
	ld h,(ix + PitchBend.pitchCoarse + 1)
	ld d,(hl)
	bit 7,d
	jp z,Positive
Negative:
	ld hl,7FFFH
	and a
	sbc hl,de
	add hl,hl
	ld a,(ix + PitchBend.downRange)
	call PitchBend_MultiplyRange
	cpl
	ld (ix + PitchBend.note),a
	ld a,h
	xor 0FFH
	ld (ix + PitchBend.detune),a
	ret m
	dec (ix + PitchBend.note)
	ret
Positive:
	res 7,d
	ex de,hl
	add hl,hl
	ld a,(ix + PitchBend.upRange)
	call PitchBend_MultiplyRange
	ld (ix + PitchBend.note),a
	ld (ix + PitchBend.detune),h
	bit 7,h
	ret z
	inc (ix + PitchBend.note)
	ret
	ENDP

; Pitch range multiplication
; hl = multiplier
; a = multiplicand (5 bits)
; ahl <- product (24-bit)
PitchBend_MultiplyRange: PROC
	ld e,l
	ld d,h
	add a,a
	add a,a
	add a,a
	add a,a
	jr c,Continue1
	ld hl,0
Continue1:
	add hl,hl
	adc a,a
	jr nc,Continue2
	add hl,de
	adc a,0
Continue2:
	add hl,hl
	adc a,a
	jr nc,Continue3
	add hl,de
	adc a,0
Continue3:
	add hl,hl
	adc a,a
	jr nc,Continue4
	add hl,de
	adc a,0
Continue4:
	add hl,hl
	adc a,a
	ret nc
	add hl,de
	adc a,0
	ret
	ENDP
