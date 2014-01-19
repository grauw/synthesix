;
; A modulation
;
Modulation: MACRO ?noteOn, ?noteOff
	value:
		db 0
	noteOn:
		dw ?noteOn
	noteOff:
		dw ?noteOff
	size:
	ENDM

; iy = this
Modulation_NoteOn:
	ld l,(iy + Modulation.noteOn + 0)
	ld h,(iy + Modulation.noteOn + 1)
	jp hl

; ix = this
Modulation_NoteOff:
	ld l,(iy + Modulation.noteOff + 0)
	ld h,(iy + Modulation.noteOff + 1)
	jp hl
