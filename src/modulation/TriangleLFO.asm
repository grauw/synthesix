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
; a <- value
TriangleLFO_NoteOn:
	ld a,(iy + TriangleLFO.keyTrigger)
	and a
	ret z
	ld (iy + TriangleLFO.counter),0
	ld a,(iy + TriangleLFO.speed)
	call TriangleLFO_Update_Return
	ret

; iy = this
; a <- value
TriangleLFO_NoteOff:
	call TriangleLFO_Update
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
