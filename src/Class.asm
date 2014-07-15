; iy = class template
; ix <- newly allocated class
; iy <- class template
; de <- newly allocated class end address
; Modifies: bc, de, hl, ix
Class_New: PROC
	ld ix,Heap_heap
Cont:
	ld c,(iy - 2)
	ld b,(iy - 1)
	call Heap_Allocate
	push de
	push iy
	pop hl
	ldir
	pop ix
	ret
	ENDP

; Allocate a new class in the upper memory heap.
; Parameters are the same as New.
Class_NewUpper:
	ld ix,Heap_heapUpper
	jp Class_New.Cont

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
