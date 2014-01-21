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
	size:
	ENDM

	dw PitchBend.size
PitchBend_class: Value 0

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
	ld l,(ix + PitchBend.pitchCoarse)
	ld h,(ix + PitchBend.pitchCoarse + 1)
	ld a,(hl)
	rla
	sub 80H
	ld (ix + PitchBend.detune),a
	ret
	ENDP
