;
; A modulation
;
Modulation: MACRO ?noteOn, ?noteOff, ?update
	noteOn:
		dw ?noteOn
	noteOff:
		dw ?noteOff
	update:
		dw ?update
	size:
	ENDM

; ix = this
Modulation_NoteOn:
	ld l,(ix + Modulation.noteOn + 0)
	ld h,(ix + Modulation.noteOn + 1)
	jp hl

; ix = this
Modulation_NoteOff:
	ld l,(ix + Modulation.noteOff + 0)
	ld h,(ix + Modulation.noteOff + 1)
	jp hl

; ix = this
Modulation_Update:
	ld l,(ix + Modulation.update + 0)
	ld h,(ix + Modulation.update + 1)
	jp hl
