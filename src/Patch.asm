;
; A voice pool
;
; Pools voices for polyphonic playback.
; When a note is played it binds a voice to it until it is
; released. When a voice is bound, it will try the next one.
; Each sound chip has a separate voice pool implementation.
;
	dw Patch_size
Patch:
Patch_noteOn: equ $ - Patch
	dw 0
Patch_noteOff: equ $ - Patch
	dw 0
Patch_controlChange: equ $ - Patch
	dw 0
Patch_mono: equ $ - Patch
	db -1;
Patch_notes: equ $ - Patch
	db -1, -1, -1, -1, -1
Patch_voices: equ $ - Patch
	dw 0, 0, 0, 0, 0  ; max 5 voices / pool
Patch_size: equ $ - Patch

Patch_NoteOn:
	ld e,(ix + Patch_noteOn + 0)
	ld d,(ix + Patch_noteOn + 1)
	ex de,hl
	jp (hl)

Patch_NoteOff:
	ld e,(ix + Patch_noteOff + 0)
	ld d,(ix + Patch_noteOff + 1)
	ex de,hl
	jp (hl)

Patch_ControlChange:
	ld e,(ix + Patch_controlChange + 0)
	ld d,(ix + Patch_controlChange + 1)
	ex de,hl
	jp (hl)
