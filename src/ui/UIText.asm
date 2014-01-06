;
; A simple text label
;
	dw UIText_size
UIText:
UIText_update: equ $ - UIText
	dw UIText_Update
UIText_buffer: equ $ - UIText
	dw 0
UIText_size: equ $ - UIText

; ix = parent
; c = x coordinate
; b = y coordinate
; hl = text (ASCIIZ)
; ix <- instance
UIText_New:
	push ix
	push hl
	push bc
	ld iy,UIText
	call Class_New
	pop bc
	pop hl
	pop iy
	call UIText_Constructor
	ret

; ix = parent
; c = x coordinate
; b = y coordinate
; hl = text (ASCIIZ)
; de <- instance
UIText_New_DE:
	call UIText_New
	push iy
	ex (sp),ix
	pop de
	ret

; ix = this
; iy = parent
; c = x coordinate
; b = y coordinate
; hl = text (ASCIIZ)
UIText_Constructor: PROC
	push hl
	call UINode_SetBuffer
	ex de,hl
	pop hl
Loop:
	ldi
	ld a,(hl)
	and a
	jp nz,Loop
	ret
	ENDP

UIText_Update:
	ret
