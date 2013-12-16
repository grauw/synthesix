; iy = class template
; ix <- new allocated class
; iy <- class template
; Modifies: bc, de, hl
Class_New:
	ld c,(iy - 2)
	ld b,(iy - 1)
	push iy
	call Heap_Allocate
	pop hl
	push de
	ldir
	pop ix
	ret

; iy = class template
; ix <- new allocated class
; iy <- class template
; Modifies: bc, de, hl
Class_NewNoInit:
	ld c,(iy - 2)
	ld b,(iy - 1)
	call Heap_Allocate
	push de
	pop ix
	ret

; iy = class template
; de = destination address
; ix <- new allocated class
; iy <- class template
; Modifies: bc, de, hl
Class_Copy:
	ld c,(iy - 2)
	ld b,(iy - 1)
	push de
	push iy
	pop hl
	ldir
	pop ix
	ret
