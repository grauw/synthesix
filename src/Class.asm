; iy = class template
; ix <- newly allocated class
; de <- newly allocated class end address
; Modifies: bc, de, hl, ix
Class_New:
	ld c,(iy - 2)
	ld b,(iy - 1)
	call Heap_Allocate
	push de
	push iy
	pop hl
	ldir
	pop ix
	ret

; iy = class template
; de = destination address
; ix <- new class
; de <- new class end address
; Modifies: bc, de, hl, ix
Class_Copy:
	ld c,(iy - 2)
	ld b,(iy - 1)
	push de
	push iy
	pop hl
	ldir
	pop ix
	ret
