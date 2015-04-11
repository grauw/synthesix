;
; Heap unit tests
;
HeapTest_Test:
	call HeapTest_TestCanAllocate
	call HeapTest_TestAllocationSimple
	call HeapTest_TestAllocationRounding
	call HeapTest_TestAllocationFragmented
	call HeapTest_TestAllocationLowerHeap
	ret

HeapTest_TestCanAllocate:
	; check available space
	ld bc,(Heap_heapUpper + Heap.capacity)
	ld ix,Heap_heapUpper
	call Heap_CanAllocate
	call nc,System_ThrowException
	ld bc,(Heap_heapUpper + Heap.capacity)
	inc bc
	ld ix,Heap_heapUpper
	call Heap_CanAllocate
	call c,System_ThrowException
	ret

HeapTest_TestAllocationSimple:
	; allocate entire heap
	ld bc,(Heap_heapUpper + Heap.capacity)
	ld ix,Heap_heapUpper
	call Heap_Allocate
	ld hl,Heap_heapUpperSpace
	and a
	sbc hl,de
	call nz,System_ThrowException
	push bc
	push de
	ld ix,Heap_heapUpper
	call Heap_GetFreeSpace
	ld a,b
	or c
	call nz,System_ThrowException
	pop de
	pop bc

	; free allocated space
	ld ix,Heap_heapUpper
	call Heap_Free
	ld ix,Heap_heapUpper
	call Heap_GetFreeSpace
	and a
	ld hl,(Heap_heapUpper + Heap.capacity)
	sbc hl,bc
	call nz,System_ThrowException
	ld bc,(Heap_heapUpper + Heap.capacity)
	ld ix,Heap_heapUpper
	call Heap_CanAllocate
	call nc,System_ThrowException
	ret

HeapTest_TestAllocationRounding:
	ld bc,1
	ld ix,Heap_heapUpper
	call Heap_Allocate
	push bc
	push de
	and a
	ld hl,4
	sbc hl,bc
	call nz,System_ThrowException
	ld ix,Heap_heapUpper
	call Heap_GetFreeSpace
	and a
	ld hl,(Heap_heapUpper + Heap.capacity)
	ld de,4
	sbc hl,de
	sbc hl,bc
	call nz,System_ThrowException
	pop de
	pop bc
	ld ix,Heap_heapUpper
	call Heap_Free
	ld ix,Heap_heapUpper
	call Heap_GetFreeSpace
	and a
	ld hl,(Heap_heapUpper + Heap.capacity)
	sbc hl,bc
	call nz,System_ThrowException
	ret

HeapTest_TestAllocationFragmented:
	; allocate two objects and then free the first
	ld bc,8
	ld ix,Heap_heapUpper
	call Heap_Allocate
	exx
	ld bc,8
	ld ix,Heap_heapUpper
	call Heap_Allocate
	push bc
	push de
	exx
	ld ix,Heap_heapUpper
	call Heap_Free
	ld ix,Heap_heapUpper
	call Heap_GetFreeSpace
	and a
	ld hl,(Heap_heapUpper + Heap.capacity)
	ld de,8
	sbc hl,de
	sbc hl,bc
	call nz,System_ThrowException

	; allocate and free remaining space
	ld hl,-8
	add hl,bc
	ld c,l
	ld b,h
	ld ix,Heap_heapUpper
	call Heap_Allocate
	push bc
	push de
	ld ix,Heap_heapUpper
	call Heap_GetFreeSpace
	and a
	ld hl,8
	sbc hl,bc
	call nz,System_ThrowException
	pop de
	pop bc
	ld ix,Heap_heapUpper
	call Heap_Free

	; free the last object
	pop de
	pop bc
	ld ix,Heap_heapUpper
	call Heap_Free
	ld bc,(Heap_heapUpper + Heap.capacity)
	ld ix,Heap_heapUpper
	call Heap_CanAllocate
	call nc,System_ThrowException
	ret

HeapTest_TestAllocationLowerHeap:
	ld bc,8
	ld ix,Heap_heap
	call Heap_Allocate
	ld ix,Heap_heap
	call Heap_Free
	ret
