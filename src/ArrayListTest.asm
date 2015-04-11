;
; ArrayList unit tests
;
ArrayListTest_Test:
	call ArrayListTest_TestAddRemoveGet
	call ArrayListTest_TestFindNearestBelow
	ret

ArrayListTest_TestAddRemoveGet:
	ld bc,4
	call ArrayList_New

	; add a value
	ld de,1234H
	call ArrayList_Add
	and a
	ld hl,0
	sbc hl,bc
	call nz,System_ThrowException
	call ArrayList_GetSize
	and a
	ld hl,1
	sbc hl,bc
	call nz,System_ThrowException
	ld bc,0
	call ArrayList_Get
	and a
	ld hl,1234H
	sbc hl,de
	call nz,System_ThrowException

	; Add another value
	ld de,5678H
	call ArrayList_Add
	and a
	ld hl,1
	sbc hl,bc
	call nz,System_ThrowException
	call ArrayList_GetSize
	and a
	ld hl,2
	sbc hl,bc
	call nz,System_ThrowException
	ld bc,1
	call ArrayList_Get
	and a
	ld hl,5678H
	sbc hl,de
	call nz,System_ThrowException
	ld bc,0
	call ArrayList_Get
	and a
	ld hl,1234H
	sbc hl,de
	call nz,System_ThrowException

	; Add another value then remove the second one
	ld de,9ABCH
	call ArrayList_Add
	ld bc,1
	call ArrayList_Remove
	call ArrayList_GetSize
	and a
	ld hl,2
	sbc hl,bc
	call nz,System_ThrowException
	ld bc,0
	call ArrayList_Get
	and a
	ld hl,1234H
	sbc hl,de
	call nz,System_ThrowException
	ld bc,1
	call ArrayList_Get
	and a
	ld hl,9ABCH
	sbc hl,de
	call nz,System_ThrowException

	; Remove the second (last) value
	ld bc,1
	call ArrayList_Remove
	call ArrayList_GetSize
	and a
	ld hl,1
	sbc hl,bc
	call nz,System_ThrowException
	ld bc,0
	call ArrayList_Get
	and a
	ld hl,1234H
	sbc hl,de
	call nz,System_ThrowException

	call ArrayList_Destroy
	ret

ArrayListTest_TestFindNearestBelow:
	ld bc,4
	call ArrayList_New

	ld de,1000H
	call ArrayList_Add
	ld de,1007H
	call ArrayList_Add
	ld de,1005H
	call ArrayList_Add
	ld de,1009H
	call ArrayList_Add

	ld de,1004H
	call ArrayList_FindNearestBelow
	and a
	sbc hl,bc
	call nz,System_ThrowException
	ld hl,0
	sbc hl,bc
	call nz,System_ThrowException
	ld hl,1000H
	sbc hl,de
	call nz,System_ThrowException

	ld de,1005H
	call ArrayList_FindNearestBelow
	and a
	sbc hl,bc
	call nz,System_ThrowException
	ld hl,2
	sbc hl,bc
	call nz,System_ThrowException
	ld hl,1005H
	sbc hl,de
	call nz,System_ThrowException

	ld de,1006H
	call ArrayList_FindNearestBelow
	and a
	sbc hl,bc
	call nz,System_ThrowException
	ld hl,2
	sbc hl,bc
	call nz,System_ThrowException
	ld hl,1005H
	sbc hl,de
	call nz,System_ThrowException

	ld de,1008H
	call ArrayList_FindNearestBelow
	and a
	sbc hl,bc
	call nz,System_ThrowException
	ld hl,1
	sbc hl,bc
	call nz,System_ThrowException
	ld hl,1007H
	sbc hl,de
	call nz,System_ThrowException

	call ArrayList_Destroy
	ret
