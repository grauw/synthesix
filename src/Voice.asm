;
; A voice
;
Voice: MACRO ?update
	update:
		dw ?update
	key:
		Value 0
	velocity:
		Value 0
	trigger:
		Value 0
	gate:
		Value 0
	size:
	ENDM

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
Voice_NoteOff:
	ld (ix + Voice.gate),0
	ret

; ix = this
Voice_Update:
	ld (ix + Voice.trigger),0
	ld l,(ix + Voice.update)
	ld h,(ix + Voice.update + 1)
	jp hl
