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

; ix = this
Modulation_Update:
	ld l,(iy + Modulation.update + 0)
	ld h,(iy + Modulation.update + 1)
	jp hl
