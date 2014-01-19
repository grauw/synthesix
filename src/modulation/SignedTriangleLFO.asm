;
; A triangle LFO
;
SignedTriangleLFO: MACRO
	super: Value 0
	speed:
		db 64
	counter:
		db 0
	sign:
		db 10101010B
	size:
	ENDM

	dw SignedTriangleLFO.size
SignedTriangleLFO_class: SignedTriangleLFO

; ix <- new class
SignedTriangleLFO_New:
	ld iy,SignedTriangleLFO_class
	call Class_New
	call SignedTriangleLFO_Constructor
	ret

; ix = this
SignedTriangleLFO_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,SignedTriangleLFO_Update
	call Clock_AddListener
	pop ix
	ret

; ix = voice
; de = this
SignedTriangleLFO_SetKeyTrigger:
	ld hl,SignedTriangleLFO_NoteOn
	call SCCVoice_AddNoteOnListener
	ret

; iy = this
SignedTriangleLFO_NoteOn:
	ld (iy + SignedTriangleLFO.counter),0
	ld (iy + SignedTriangleLFO.sign),10101010B
	ret

; iy = this
; a <- value (one’s complement)
SignedTriangleLFO_Update: PROC
	ld a,(iy + SignedTriangleLFO.counter)
	add a,(iy + SignedTriangleLFO.speed)
	ld (iy + SignedTriangleLFO.counter),a
	call c,FlipSign
	bit 7,(iy + SignedTriangleLFO.sign)
	jp nz,Negative
	ld (iy + SignedTriangleLFO.super.value),a
	and a
	ret p
	neg
	dec a
	ld (iy + SignedTriangleLFO.super.value),a
	ret
Negative:
	ld (iy + SignedTriangleLFO.super.value),a
	and a
	ret m
	cpl
	ld (iy + SignedTriangleLFO.super.value),a
	ret
FlipSign:
	rrc (iy + SignedTriangleLFO.sign)
	ret
	ENDP
