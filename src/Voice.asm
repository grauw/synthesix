;
; A voice
;
Voice: MACRO ?noteOn, ?noteOff, ?update
	noteOn:
		dw ?noteOn
	noteOff:
		dw ?noteOff
	update:
		dw ?update
	size:
	ENDM

; ix = this
Voice_NoteOn:
	ld l,(ix + Voice.noteOn)
	ld h,(ix + Voice.noteOn + 1)
	jp hl

; ix = this
Voice_NoteOff:
	ld l,(ix + Voice.noteOff)
	ld h,(ix + Voice.noteOff + 1)
	jp hl

; ix = this
Voice_Update:
	ld l,(ix + Voice.update)
	ld h,(ix + Voice.update + 1)
	jp hl
