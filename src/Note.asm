;
; A note
;
Note: MACRO
	outputs:
	key:
		Value 0
	velocity:
		Value 0
	gate:
		Value 0
	trigger:
		Value 0
	offVelocity:
		Value 0
	outputsEnd:
	inputs:
	inputsEnd:
	labels: equ Note_labels
	_size:
	ENDM

	dw Note._size
Note_class: Note

; ix, de <- new object
Note_New:
	ld iy,Note_class
	call Class_New
	call Note_Constructor
	ret

; ix = this
; ix, de <- this
Note_Constructor: PROC
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60HzLate
	ld hl,Note_UpdateLate
	call Clock_AddListener
	pop ix
	ret
	ENDP

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
Note_NoteOn:
	ld (ix + Note.key),b
	ld (ix + Note.velocity),c
	ld (ix + Note.offVelocity),0
	ld (ix + Note.trigger),7FH
	ld (ix + Note.gate),7FH
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
Note_NoteOff:
	ld (ix + Note.gate),0
	ld (ix + Note.offVelocity),c
	ret

; ix = this
Note_UpdateLate:
	ld (ix + Note.trigger),0
	ret

;
Note_labels:
	db "Note",0
	db "Key",0
	db "Velocity",0
	db "Gate",0
	db "Trigger",0
	db "Off velocity",0
