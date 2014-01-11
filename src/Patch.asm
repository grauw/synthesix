;
; A voice pool
;
; Pools voices for polyphonic playback.
; When a note is played it binds a voice to it until it is
; released. When a voice is bound, it will try the next one.
; Each sound chip has a separate voice pool implementation.
;
Patch: MACRO ?noteOn, ?noteOff, ?controlChange, ?update
	noteOn:
		dw ?noteOn
	noteOff:
		dw ?noteOff
	controlChange:
		dw ?controlChange
	update:
		dw ?update
	size:
	ENDM

Patch_NoteOn:
	ld l,(ix + Patch.noteOn + 0)
	ld h,(ix + Patch.noteOn + 1)
	jp hl

Patch_NoteOff:
	ld l,(ix + Patch.noteOff + 0)
	ld h,(ix + Patch.noteOff + 1)
	jp hl

Patch_ControlChange:
	ld l,(ix + Patch.controlChange + 0)
	ld h,(ix + Patch.controlChange + 1)
	jp hl

Patch_Update:
	ld l,(ix + Patch.update + 0)
	ld h,(ix + Patch.update + 1)
	jp hl
