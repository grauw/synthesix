;
; A triangle LFO
;
TriangleLFO: MACRO
	super: Value 0
	speed:
		db 2
	counter:
		db 0
	size:
	ENDM

	dw TriangleLFO.size
TriangleLFO_class: TriangleLFO

; ix <- new class
TriangleLFO_New:
	ld iy,TriangleLFO_class
	call Class_New
	call TriangleLFO_Constructor
	ret

; ix = this
TriangleLFO_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,TriangleLFO_Update
	call Clock_AddListener
	pop ix
	ret

; ix = voice
; de = this
TriangleLFO_SetKeyTrigger:
	ld hl,TriangleLFO_NoteOn
	call SCCVoice_AddNoteOnListener
	ret

; ix = this
TriangleLFO_NoteOn:
	ld (ix + TriangleLFO.counter),0
	ret

; ix = this
; a <- value (one’s complement)
TriangleLFO_Update: PROC
	ld a,(ix + TriangleLFO.counter)
	add a,(ix + TriangleLFO.speed)
	ld (ix + TriangleLFO.counter),a
	jp p,Positive
	cpl
Positive:
	ld (ix + TriangleLFO.super.value),a
	ret
	ENDP
