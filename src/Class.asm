; iy = class template
; ix <- newly allocated class
; iy <- class template
; de <- newly allocated class end address
; Modifies: bc, de, hl, ix
Class_New:
	ld c,(iy - 2)
	ld b,(iy - 1)
	ld ix,Heap_heap
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
; iy <- class template
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
