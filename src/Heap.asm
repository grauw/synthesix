; bc = number of bytes to allocate
; bc <- allocated space
; de <- allocated memory start address
; hl <- allocated memory end address
; Modifies: bc, de, hl
; Throws out of memory exception
Heap_Allocate:
	ld hl,(Heap_heapCapacity)
	and a
	sbc hl,bc
	jr c,Heap_Allocate_Throw
	ld hl,(Heap_heapCapacity)
	ld de,(Heap_heapPosition)
	ld h,d
	ld l,e
	add hl,bc
	ld (Heap_heapPosition),hl
	ret
Heap_Allocate_Throw:
	ld hl,Heap_outOfHeapException
	jp System_ThrowExceptionWithMessage

Heap_outOfHeapException:
	db "Out of heap space.",0
