;
; A list of 16-bit values
;
ArrayList: MACRO
	size:
		dw 0
	capacity:
		dw 0
	buffer:
		dw 0
	_size:
	ENDM

	dw ArrayList._size
ArrayList_class: ArrayList

; bc = capacity
; ix, de <- new object
ArrayList_New:
	push bc
	ld iy,ArrayList_class
	call Class_New
	pop bc
	jp ArrayList_Constructor

; bc = capacity
; ix = this
; ix, de <- this
ArrayList_Constructor:
	ld (ix + ArrayList.capacity),c
	ld (ix + ArrayList.capacity + 1),b
	sla c
	rl b
	push ix
	ld ix,Heap_main
	call Heap_Allocate
	pop ix
	ld (ix + ArrayList.buffer),e
	ld (ix + ArrayList.buffer + 1),d
	ld e,ixl
	ld d,ixh
	ret

; ix = this
ArrayList_Destroy:
	call ArrayList_Destructor
	ld iy,ArrayList_class
	call Class_Destroy
	ret

; ix = this
; ix <- this
ArrayList_Destructor:
	ld e,(ix + ArrayList.buffer)
	ld d,(ix + ArrayList.buffer + 1)
	ld c,(ix + ArrayList.capacity)
	ld b,(ix + ArrayList.capacity + 1)
	sla c
	rl b
	push ix
	ld ix,Heap_main
	call Heap_Free
	pop ix
	ret

; ix = this
; bc <- size
ArrayList_GetSize:
	ld c,(ix + ArrayList.size)
	ld b,(ix + ArrayList.size + 1)
	ret

; bc = index
; ix = this
; de <- value
; Modifies: f, de, hl
ArrayList_Get:
	call ArrayList_GetElement
	ld e,(hl)
	inc hl
	ld d,(hl)
	ret

; bc = index
; ix = this
; hl <- element address
; Modifies: f, hl
ArrayList_GetElement:
	ld l,(ix + ArrayList.size)
	ld h,(ix + ArrayList.size + 1)
	scf
	sbc hl,bc
	call c,System_ThrowException
	ld l,(ix + ArrayList.buffer)
	ld h,(ix + ArrayList.buffer + 1)
	add hl,bc
	add hl,bc
	ret

; de = value to add
; ix = this
; bc <- index of added element
; Modifies: f, bc, hl
ArrayList_Add:
	ld c,(ix + ArrayList.size)
	ld b,(ix + ArrayList.size + 1)
	inc bc
	ld (ix + ArrayList.size),c
	ld (ix + ArrayList.size + 1),b
	ld l,(ix + ArrayList.capacity)
	ld h,(ix + ArrayList.capacity + 1)
	and a
	sbc hl,bc
	call c,System_ThrowException
	dec bc
	ld l,(ix + ArrayList.buffer)
	ld h,(ix + ArrayList.buffer + 1)
	add hl,bc
	add hl,bc
	ld (hl),e
	inc hl
	ld (hl),d
	ret

; ix = this
; bc = element index to remove
; Modifies: f, bc, de, hl
ArrayList_Remove:
	ld l,(ix + ArrayList.size)
	ld h,(ix + ArrayList.size + 1)
	dec hl
	ld (ix + ArrayList.size),l
	ld (ix + ArrayList.size + 1),h
	and a
	sbc hl,bc
	call c,System_ThrowException
	add hl,hl
	ret z
	push hl
	ld l,(ix + ArrayList.buffer)
	ld h,(ix + ArrayList.buffer + 1)
	add hl,bc
	add hl,bc
	ld e,l
	ld d,h
	inc hl
	inc hl
	pop bc
	ldir
	ret

; de = value to find
; ix = this
; bc <- index
; hl <- index
; Modifies: af, bc, hl
ArrayList_Find: PROC
	ld c,(ix + ArrayList.size)
	ld b,(ix + ArrayList.size + 1)
	push bc
	ld l,(ix + ArrayList.buffer)
	ld h,(ix + ArrayList.buffer + 1)
Loop:
	ld a,b
	or c
	call z,System_ThrowException
	ld a,(hl)
	inc hl
	cp e
	jp nz,Next
	ld a,(hl)
	cp d
	jp z,Found
Next:
	inc hl
	dec bc
	jp Loop
Found:
	pop hl
	sbc hl,bc
	ld c,l
	ld b,h
	ret
	ENDP

;
; Finds the nearest entry which is lower or equal to the given value.
;
; de = value to find
; ix = this
; bc <- index
; de <- actual address
; hl <- index
; Modifies: all but ix
ArrayList_FindNearestBelow: PROC
	ld c,(ix + ArrayList.buffer)
	ld b,(ix + ArrayList.buffer + 1)
	ld iyl,c
	ld iyh,b
	ld bc,0                         ; bc = best match (0 - distance)
	exx
	ld c,(ix + ArrayList.size)      ; bc' = array index
	ld de,0                         ; de' = match
	ld hl,-1                        ; hl' = best match index
	ld b,(ix + ArrayList.size + 1)
	add iy,bc                       ; iy = current position (counts backwards)
	add iy,bc
	exx
Loop:
	exx
Loop2:
	ld a,b
	or c
	jr z,Done
	dec bc
	exx
	dec iy
	dec iy
	ld l,(iy + 0)  ; hl = entry
	ld h,(iy + 1)  ; de = search value
	sbc hl,de
	jr z,Found
	jr nc,Loop
	and a
	sbc hl,bc
	jr c,Loop
	add hl,bc
	ld c,l  ; bc = new best match distance
	ld b,h
	exx
	ld l,c  ; hl' = new best match index
	ld h,b
	jp Loop2
Found:
	push de
	exx
	pop de
	ld l,c
	ld h,b
	ret
Done:
	bit 7,h
	call nz,System_ThrowException
	exx
	ex de,hl
	add hl,bc
	push hl
	exx
	pop de
	ld c,l
	ld b,h
	ret
	ENDP
