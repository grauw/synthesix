;
; A heap
;
Heap: MACRO ?start, ?size
	position:
		dw ?start
	capacity:
		dw ?size
	size:
	ENDM

; ix = this
; bc = number of bytes to allocate
; bc <- allocated space
; de <- allocated memory start address
; hl <- allocated memory end address
; Modifies: f, bc, de, hl
; Throws out of memory exception
Heap_Allocate: PROC
	and a
	ld hl,0
	sbc hl,bc
	call z,System_ThrowException
	ld l,(ix + Heap.capacity)
	ld h,(ix + Heap.capacity + 1)
	and a
	sbc hl,bc
	jr c,Throw
	ld (ix + Heap.capacity),l
	ld (ix + Heap.capacity + 1),h
	ld e,(ix + Heap.position)
	ld d,(ix + Heap.position + 1)
	ld l,e
	ld h,d
	add hl,bc
	ld (ix + Heap.position),l
	ld (ix + Heap.position + 1),h
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
	push af
	push bc
	push de
	push hl
	ld l,e
	ld h,d
	ld (de),a
	inc de
	dec bc
	ld a,b
	or c
	jr z,Skip
	ldir
Skip:
	pop hl
	pop de
	pop bc
	pop af
	ret
	ENDP

;
	SECTION RAM

Heap_heap:
	Heap 8000H, 3000H

Heap_heapUpper:
	Heap Heap_heapUpperSpace, 100H

Heap_heapUpperSpace:
	ds 100H

	ENDS
