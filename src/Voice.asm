;
; A voice
;
Voice: MACRO
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

	dw Voice.size
Voice_class: Voice

; ix <- new class
Voice_New:
	ld iy,Voice_class
	call Class_New
	call Voice_Constructor
	ret

; ix = this
; ix <- this
Voice_Constructor: PROC
	ret
	ENDP

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
Voice_NoteOn:
	ld (ix + Voice.key),b
	ld (ix + Voice.velocity),c
	ld (ix + Voice.trigger),7FH
	ld (ix + Voice.gate),7FH
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
Voice_NoteOff:
	ld (ix + Voice.gate),0
	ld (ix + Voice.offVelocity),c
	ret

; ix = this
Voice_Update:
	ld (ix + Voice.trigger),0
	ret
