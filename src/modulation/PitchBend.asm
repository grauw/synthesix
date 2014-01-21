;
; A pitch bend
;
PitchBend: MACRO
	noteValue:
		Value 0
	detuneValue:
		Value 0
	depthFine:
		dw 0
	depthCoarse:
		dw 0
	inputNote:
		dw 0
	inputDetune:
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
	ld l,(ix + PitchBend.inputNote)
	ld h,(ix + PitchBend.inputNote + 1)
	ld a,(hl)
	ld (ix + PitchBend.noteValue),a
	ld l,(ix + PitchBend.depthFine)
	ld h,(ix + PitchBend.depthFine + 1)
	ld a,(hl)
	add a,a
	add a,a
	ld l,(ix + PitchBend.depthCoarse)
	ld h,(ix + PitchBend.depthCoarse + 1)
	ld a,(hl)
	rla
	sub 80H
	ld l,(ix + PitchBend.inputDetune)
	ld h,(ix + PitchBend.inputDetune + 1)
	and a
	jp m,Subtract
	add a,(hl)
	ld (ix + PitchBend.detuneValue),a
	ret po
	inc (ix + PitchBend.noteValue)
	inc (ix + PitchBend.detuneValue)
	ret
Subtract:
	inc a
	add a,(hl)
	ld (ix + PitchBend.detuneValue),a
	ret po
	dec (ix + PitchBend.noteValue)
	dec (ix + PitchBend.detuneValue)
	ret
	ENDP
