;
; A triangle LFO
;
TriangleLFO: MACRO
	value:
		Value 0
	speed:
		db 2
	trigger:
		dw Value_values.0
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

; ix = this
TriangleLFO_Reset:
	ld (ix + TriangleLFO.counter),0
	ret

; ix = this
TriangleLFO_Update: PROC
	ld l,(ix + TriangleLFO.trigger)
	ld h,(ix + TriangleLFO.trigger + 1)
	bit 6,(hl)
	call nz,TriangleLFO_Reset
	ld a,(ix + TriangleLFO.counter)
	add a,(ix + TriangleLFO.speed)
	ld (ix + TriangleLFO.counter),a
	jp p,Positive
	cpl
Positive:
	ld (ix + TriangleLFO.value),a
	ret
	ENDP
