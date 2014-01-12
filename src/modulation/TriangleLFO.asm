;
; An AR envelope
;
TriangleLFO: MACRO
	super:
		Modulation TriangleLFO_NoteOn, TriangleLFO_NoteOff, TriangleLFO_Update
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

; iy = this
TriangleLFO_NoteOn:
	ld a,(iy + TriangleLFO.keyTrigger)
	and a
	ret z
	ld (iy + TriangleLFO.counter),0
	ld (iy + TriangleLFO.sign),10101010B
	ret

; iy = this
TriangleLFO_NoteOff:
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
	and a
	ret p
	neg
	dec a
	ret
Negative:
	and a
	ret m
	cpl
	ret
FlipSign:
	rrc (iy + TriangleLFO.sign)
	ret
	ENDP
