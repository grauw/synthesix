;
; A MIDI channel
;
; One channel can control multiple timbres.
; It contains one voice pool per sound chip / patch.
; All MIDI messages are forwarded to the voice pools.
;
	dw Channel_size
Channel:
Channel_MAX_VOICE_POOLS: equ 2
Channel_patches: equ $ - Channel
	REPT Channel_MAX_VOICE_POOLS
	dw 0
	ENDM
Channel_size: equ $ - Channel

; ix <- new class
Channel_New:
	ld iy,Channel
	call Class_New
	push ix
	call SCCPatch_New
	push ix
	pop hl
	pop ix
	call Channel_AddPatch
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
Channel_NoteOn:
	REPT Channel_MAX_VOICE_POOLS, ?pool
	ld e,(ix + Channel_patches + ?pool * 2)
	ld d,(ix + Channel_patches + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	push af
	push bc
	ld ixl,e
	ld ixh,d
	call Patch_NoteOn
	pop bc
	pop af
	pop ix
	ENDM
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
Channel_NoteOff:
	REPT Channel_MAX_VOICE_POOLS, ?pool
	ld e,(ix + Channel_patches + ?pool * 2)
	ld d,(ix + Channel_patches + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	push af
	push bc
	ld ixl,e
	ld ixh,d
	call Patch_NoteOff
	pop bc
	pop af
	pop ix
	ENDM
	ret

; ix = this
; a = value
; b = controller
Channel_ControlChange:
	REPT Channel_MAX_VOICE_POOLS, ?pool
	ld e,(ix + Channel_patches + ?pool * 2)
	ld d,(ix + Channel_patches + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	push af
	push bc
	ld ixl,e
	ld ixh,d
	call Patch_ControlChange
	pop bc
	pop af
	pop ix
	ENDM
	ret

; ix = this
; b = delta time
Channel_Update:
	REPT Channel_MAX_VOICE_POOLS, ?pool
	ld e,(ix + Channel_patches + ?pool * 2)
	ld d,(ix + Channel_patches + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	push bc
	ld ixl,e
	ld ixh,d
	call Patch_Update
	pop bc
	pop ix
	ENDM
	ret

; ix = this
; hl = voice pool
Channel_AddPatch:
	REPT Channel_MAX_VOICE_POOLS, ?pool
	PROC
	LOCAL Channel_AddPatch_Next
	ld a,(ix + Channel_patches + ?pool * 2 + 1)
	and a
	jr nz,Channel_AddPatch_Next
	ld (ix + Channel_patches + ?pool * 2),l
	ld (ix + Channel_patches + ?pool * 2 + 1),h
	ret
Channel_AddPatch_Next:
	ENDP
	ENDM
	call System_ThrowException
