;
; A triangle LFO
;
LFOTriangleBipolar: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	speed:
		dw Constants_instance + 48
	reset:
		dw Constants_instance + 0
	inputsEnd:
	counter:
		db 0
	sign:
		db 10101010B
	labels: equ LFOTriangleBipolar_labels
	_size:
	ENDM

	dw LFOTriangleBipolar._size
LFOTriangleBipolar_class: LFOTriangleBipolar

; ix, de <- new object
LFOTriangleBipolar_New:
	ld iy,LFOTriangleBipolar_class
	call Class_New
	call LFOTriangleBipolar_Constructor
	ret

; ix = this
; ix, de <- this
LFOTriangleBipolar_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,LFOTriangleBipolar_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
LFOTriangleBipolar_Reset:
	ld (ix + LFOTriangleBipolar.counter),0
	ld (ix + LFOTriangleBipolar.sign),10101010B
	ret

; ix = this
LFOTriangleBipolar_Update: PROC
	ld l,(ix + LFOTriangleBipolar.reset)
	ld h,(ix + LFOTriangleBipolar.reset + 1)
	bit 6,(hl)
	call nz,LFOTriangleBipolar_Reset
	ld l,(ix + LFOTriangleBipolar.speed)
	ld h,(ix + LFOTriangleBipolar.speed + 1)
	ld a,(ix + LFOTriangleBipolar.counter)
	add a,(hl)
	ld (ix + LFOTriangleBipolar.counter),a
	jp nc,NoSignChange
	rrc (ix + LFOTriangleBipolar.sign)  ; flip sign
NoSignChange:
	ld (ix + LFOTriangleBipolar.value),a
	bit 7,(ix + LFOTriangleBipolar.sign)
	jr nz,Negative
	and a
	ret p
	neg
	dec a
	ld (ix + LFOTriangleBipolar.value),a
	ret
Negative:
	and a
	ret m
	cpl
	ld (ix + LFOTriangleBipolar.value),a
	ret
	ENDP

;
LFOTriangleBipolar_labels:
	db 246,247," LFO",0
	db "Value",0
	db "Speed",0
	db "Reset",0
