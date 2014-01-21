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
	upRange:    ;bend range (rounded down to powers of 2)
		db 2
	downRange:  ;bend range (rounded down to powers of 2)
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
	ld a,(hl)
	add a,a
	add a,a
	ld e,a
	ld l,(ix + PitchBend.pitchCoarse)
	ld h,(ix + PitchBend.pitchCoarse + 1)
	ld a,(hl)
	adc a,a
	add a,80H
	ld d,a
	ex de,hl
	add hl,hl
	jr nc,Positive
Negative:
	ld e,-1
	rl e
	ld a,(ix + PitchBend.downRange)
	call PitchBend_MultiplyRange
	ld (ix + PitchBend.note),e
	ld (ix + PitchBend.detune),h
	bit 7,h
	ret nz
	dec (ix + PitchBend.note)
	ret
Positive:
	ld e,0
	rl e
	ld a,(ix + PitchBend.upRange)
	call PitchBend_MultiplyRange
	ld (ix + PitchBend.note),e
	ld (ix + PitchBend.detune),h
	bit 7,h
	ret z
	inc (ix + PitchBend.note)
	ret
	ENDP

PitchBend_MultiplyRange:
	srl a
	ret z
	add hl,hl
	rl e
	jp PitchBend_MultiplyRange
