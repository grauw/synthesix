; iy = class template
; ix <- new object
; Modifies: af, bc, de, hl, ix
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

; Allocate a new object in the upper memory heap.
; Parameters are the same as New.
Class_NewUpper:
	ld ix,Heap_heapUpper
	jp Class_New.Cont

; iy = class template
; de = destination address
; ix <- new object
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
