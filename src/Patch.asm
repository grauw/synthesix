;
; A voice pool
;
; Pools voices for polyphonic playback.
; When a note is played it binds a voice to it until it is
; released. When a voice is bound, it will try the next one.
; Each sound chip has a separate voice pool implementation.
;
Patch: MACRO ?noteOn, ?noteOff, ?update
	noteOn:
		dw ?noteOn
	noteOff:
		dw ?noteOff
	update:
		dw ?update
	size:
	ENDM

; ix = this
Patch_NoteOn:
	ld l,(ix + Patch.noteOn + 0)
	ld h,(ix + Patch.noteOn + 1)
	jp hl

; ix = this
Patch_NoteOff:
	ld l,(ix + Patch.noteOff + 0)
	ld h,(ix + Patch.noteOff + 1)
	jp hl

; ix = this
Patch_Update:
	ld l,(ix + Patch.update + 0)
	ld h,(ix + Patch.update + 1)
	jp hl
