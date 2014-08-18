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
		dw Constants_instance + 0
	augendDetune:
		dw Constants_instance + 0
	addendNote:
		dw Constants_instance + 0
	addendDetune:
		dw Constants_instance + 0
	inputsEnd:
	labels: equ AddPitch_labels
	_size:
	ENDM

	dw AddPitch._size
AddPitch_class: AddPitch

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
	ld ix,Updater_60Hz
	ld hl,AddPitch_Update
	call Updater_AddListener
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

;
AddPitch_labels:
	db "Add pitch",0
	db "Note",0
	db "Detune",0
	db "Note A",0
	db "DetuneA",0
	db "Note B",0
	db "DetuneB",0
