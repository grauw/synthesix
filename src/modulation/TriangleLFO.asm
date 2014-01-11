;
; An AR envelope
;
TriangleLFO: MACRO
	super:
		Modulation TriangleLFO_NoteOn, TriangleLFO_NoteOff, TriangleLFO_Update
	speed:
		db 30
	keyTrigger:
		db 0
	counter:
		db 0
	size:
	ENDM

	dw TriangleLFO.size
TriangleLFO_class: TriangleLFO

; iy = this
TriangleLFO_NoteOn:
	ld a,(iy + TriangleLFO.keyTrigger)
	and a
	ret z
	ld (iy + TriangleLFO.counter),0
	ret

; iy = this
TriangleLFO_NoteOff:
	ret

; iy = this
; a <- value
TriangleLFO_Update:
	ld a,(iy + TriangleLFO.counter)
	add a,(iy + TriangleLFO.speed)
	ld (iy + TriangleLFO.counter),a
TriangleLFO_Update_Return:
	and a
	ret p
	neg
	dec a
	ret
