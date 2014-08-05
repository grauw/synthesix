;
; A pitch bend
;
AddPitch: MACRO
	outputs:
	note:
		Value 0
	detune:
		Value 0
	outputsEnd:
	inputs:
	augendNote:
		dw Value_values.0
	augendDetune:
		dw Value_values.0
	addendNote:
		dw Value_values.0
	addendDetune:
		dw Value_values.0
	inputsEnd:
	_size:
	ENDM

	dw AddPitch._size
AddPitch_class: Value 0

; ix, de <- new object
AddPitch_New:
	ld iy,AddPitch_class
	call Class_New
	call AddPitch_Constructor
	ret

; ix = this
; ix, de <- this
AddPitch_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,AddPitch_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
AddPitch_Update: PROC
	ld l,(ix + AddPitch.augendNote)
	ld h,(ix + AddPitch.augendNote + 1)
	ld a,(hl)
	ld l,(ix + AddPitch.addendNote)
	ld h,(ix + AddPitch.addendNote + 1)
	and a
	jp p,AddNote
	inc a
AddNote:
	add a,(hl)
	ld (ix + AddPitch.note),a
	ld l,(ix + AddPitch.augendDetune)
	ld h,(ix + AddPitch.augendDetune + 1)
	ld a,(hl)
	ld l,(ix + AddPitch.addendDetune)
	ld h,(ix + AddPitch.addendDetune + 1)
	and a
	jp m,SubtractDetune
	add a,(hl)
	ld (ix + AddPitch.detune),a
	ret po
	inc (ix + AddPitch.note)
	inc (ix + AddPitch.detune)
	ret
SubtractDetune:
	inc a
	add a,(hl)
	ld (ix + AddPitch.detune),a
	ret po
	dec (ix + AddPitch.note)
	dec (ix + AddPitch.detune)
	ret
	ENDP
