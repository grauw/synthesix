;
; A pitch bend
;
PitchBend: MACRO
	outputs:
	note:
		Value 0
	detune:
		Value 0
	outputsEnd:
	inputs:
	pitchCoarse:
		dw Constants_instance + 0
	pitchFine:
		dw Constants_instance + 0
	rangeUp:    ;max range is 31 notes
		dw Constants_instance + 2
	rangeDown:  ;max range is 31 notes
		dw Constants_instance + 2
	inputsEnd:
	labels: equ PitchBend_labels
	_size:
	ENDM

	dw PitchBend._size
PitchBend_class: PitchBend

; ix, de <- new object
PitchBend_New:
	ld iy,PitchBend_class
	call Class_New
	call PitchBend_Constructor
	ret

; ix = this
; ix, de <- this
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
	ld e,(ix + PitchBend.rangeDown)
	ld d,(ix + PitchBend.rangeDown + 1)
	ld a,(de)
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
	ld e,(ix + PitchBend.rangeUp)
	ld d,(ix + PitchBend.rangeUp + 1)
	ld a,(de)
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

;
PitchBend_labels:
	db "Pitch bend",0
	db "Note",0
	db "Detune",0
	db "Bend C",0
	db "Bend F",0
	db "Range U",0
	db "Range D",0
