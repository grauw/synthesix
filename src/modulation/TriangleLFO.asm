;
; An AR envelope
;
TriangleLFO: MACRO
	super: Modulation
	speed:
		db 64
	keyTrigger:
		db 0
	counter:
		db 0
	sign:
		db 10101010B
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

; iy = this
TriangleLFO_NoteOn:
	ld a,(iy + TriangleLFO.keyTrigger)
	and a
	ret z
	ld (iy + TriangleLFO.counter),0
	ld (iy + TriangleLFO.sign),10101010B
	ret

; iy = this
; a <- value (one’s complement)
TriangleLFO_Update: PROC
	ld a,(iy + TriangleLFO.counter)
	add a,(iy + TriangleLFO.speed)
	ld (iy + TriangleLFO.counter),a
	call c,FlipSign
	bit 7,(iy + TriangleLFO.sign)
	jp nz,Negative
	ld (iy + TriangleLFO.super.value),a
	and a
	ret p
	neg
	dec a
	ld (iy + TriangleLFO.super.value),a
	ret
Negative:
	ld (iy + TriangleLFO.super.value),a
	and a
	ret m
	cpl
	ld (iy + TriangleLFO.super.value),a
	ret
FlipSign:
	rrc (iy + TriangleLFO.sign)
	ret
	ENDP
