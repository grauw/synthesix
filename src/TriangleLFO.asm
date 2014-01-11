;
; An AR envelope
;
TriangleLFO: MACRO
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

; ix = this
; a <- value
TriangleLFO_NoteOn:
	ld a,(ix + TriangleLFO.keyTrigger)
	and a
	ret z
	ld (ix + TriangleLFO.counter),0
	ld a,(ix + TriangleLFO.speed)
	call TriangleLFO_Update_Return
	ret

; ix = this
; a <- value
TriangleLFO_NoteOff:
	call TriangleLFO_Update
	ret

; ix = this
; b = time delta
; a <- value
; b <- time delta
TriangleLFO_Update:
	ld a,(ix + TriangleLFO.counter)
	ld h,b
TriangleLFO_Update_Loop:
	add a,(ix + TriangleLFO.speed)
	djnz TriangleLFO_Update_Loop
	ld b,h
	ld (ix + TriangleLFO.counter),a
TriangleLFO_Update_Return:
	and a
	ret p
	neg
	dec a
	ret
