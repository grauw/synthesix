;
; A triangle LFO
;
LFOTriangleSigned: MACRO
	value:
		Value 0
	speed:
		db 48
	trigger:
		dw Value_values.0
	counter:
		db 0
	sign:
		db 10101010B
	_size:
	ENDM

	dw LFOTriangleSigned._size
LFOTriangleSigned_class: LFOTriangleSigned

; ix, de <- new object
LFOTriangleSigned_New:
	ld iy,LFOTriangleSigned_class
	call Class_New
	call LFOTriangleSigned_Constructor
	ret

; ix = this
; ix, de <- this
LFOTriangleSigned_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,LFOTriangleSigned_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
LFOTriangleSigned_Reset:
	ld (ix + LFOTriangleSigned.counter),0
	ld (ix + LFOTriangleSigned.sign),10101010B
	ret

; ix = this
LFOTriangleSigned_Update: PROC
	ld l,(ix + LFOTriangleSigned.trigger)
	ld h,(ix + LFOTriangleSigned.trigger + 1)
	bit 6,(hl)
	call nz,LFOTriangleSigned_Reset
	ld a,(ix + LFOTriangleSigned.counter)
	add a,(ix + LFOTriangleSigned.speed)
	ld (ix + LFOTriangleSigned.counter),a
	jp nc,NoSignChange
	rrc (ix + LFOTriangleSigned.sign)  ; flip sign
NoSignChange:
	ld (ix + LFOTriangleSigned.value),a
	bit 7,(ix + LFOTriangleSigned.sign)
	jr nz,Negative
	and a
	ret p
	neg
	dec a
	ld (ix + LFOTriangleSigned.value),a
	ret
Negative:
	and a
	ret m
	cpl
	ld (ix + LFOTriangleSigned.value),a
	ret
	ENDP
