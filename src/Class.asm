; iy = class template
; ix <- new object
; Modifies: af, bc, de, hl, ix
Class_New: PROC
	ld ix,Heap_main
Cont:
	ld c,(iy - 2)
	ld b,(iy - 1)
	call Heap_Allocate
	ld ixl,e
	ld ixh,d
	push iy
	pop hl
	ldir
	ret
	ENDP

; Allocate a new object in the upper memory heap.
; Parameters are the same as New.
Class_NewUpper:
	ld ix,Heap_upper
	jp Class_New.Cont

; iy = class template
; ix = this
Class_Destroy:
	ld c,(iy - 2)
	ld b,(iy - 1)
	ld e,ixl
	ld d,ixh
	ld ix,Heap_main
	call Heap_IsInHeap
	jp c,Heap_Free
	ld ix,Heap_upper
	call Heap_IsInHeap
	jp c,Heap_Free
	call System_ThrowException
	ret

; iy = class template
; de = destination address
; ix <- new object
; Modifies: bc, de, hl, ix
Class_Copy:
	ld c,(iy - 2)
	ld b,(iy - 1)
	ld ixl,e
	ld ixh,d
	push iy
	pop hl
	ldir
	ret
