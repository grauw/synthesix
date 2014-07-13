;
; A note
;
Note: MACRO
	key:
		Value 0
	velocity:
		Value 0
	offVelocity:
		Value 0
	trigger:
		Value 0
	gate:
		Value 0
	size:
	ENDM

	dw Note.size
Note_class: Note

; ix <- new class
Note_New:
	ld iy,Note_class
	call Class_New
	call Note_Constructor
	ret

; ix = this
; ix <- this
Note_Constructor: PROC
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
Note_Update:
	ld (ix + Note.trigger),0
	ret
