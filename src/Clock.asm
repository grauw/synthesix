Clock: MACRO
	value:
		dw 0
	ENDM

; ix = this
Clock_Update:
	ld a,(ix + Clock.value)
	inc a
	ld (ix + Clock.value),a
	ret nc
	ld a,(ix + Clock.value + 1)
	inc a
	ld (ix + Clock.value + 1),a
	ret

;
	SECTION RAM

Clock_60Hz:
	Clock

	ENDS
