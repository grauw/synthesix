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
	dw System_ThrowException
Patch_noteOff: equ $ - Patch
	dw System_ThrowException
Patch_controlChange: equ $ - Patch
	dw System_ThrowException
Patch_update: equ $ - Patch
	dw System_ThrowException
Patch_size: equ $ - Patch

Patch_NoteOn:
	ld l,(ix + Patch_noteOn + 0)
	ld h,(ix + Patch_noteOn + 1)
	jp (hl)

Patch_NoteOff:
	ld l,(ix + Patch_noteOff + 0)
	ld h,(ix + Patch_noteOff + 1)
	jp (hl)

Patch_ControlChange:
	ld l,(ix + Patch_controlChange + 0)
	ld h,(ix + Patch_controlChange + 1)
	jp (hl)

Patch_Update:
	ld l,(ix + Patch_update + 0)
	ld h,(ix + Patch_update + 1)
	jp (hl)
