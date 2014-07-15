; bc = number of bytes to allocate
; bc <- allocated space
; de <- allocated memory start address
; hl <- allocated memory end address
; Modifies: bc, de, hl
; Throws out of memory exception
Heap_Allocate: PROC
	ld hl,(Heap_heapCapacity)
	and a
	sbc hl,bc
	jr c,Throw
	ld hl,(Heap_heapCapacity)
	ld de,(Heap_heapPosition)
	ld l,e
	ld h,d
	add hl,bc
	ld (Heap_heapPosition),hl
	ret
Throw:
	ld hl,Heap_outOfHeapException
	jp System_ThrowExceptionWithMessage
	ENDP

Heap_outOfHeapException:
	db "Out of heap space.",0

; Allocates, then clears the allocated space.
; a = clear value
; Remaining parameters are the same as Allocate
Heap_AllocateClear: PROC
	call Heap_Allocate
	push bc
	push de
	push hl
	ld l,e
	ld h,d
	ld (de),a
	inc de
	dec bc
	jr z,Skip
	ldir
Skip:
	pop hl
	pop de
	pop bc
	ret
	ENDP

;
	SECTION RAM

Heap_heapPosition:
	dw Heap_start
Heap_heapCapacity:
	dw Heap_size

	ENDS
