Keys_Init:
	ld a,0
	ld (CLIKSW),a  ; disable key click
	call Keys_Scan_updateLast
	ret

Keys_Scan:
	ld de,NEWKEY
	ld hl,Keys_lastScan
	ld ix,Keys_noteMapping
	REPT 11  ; just the first 6 rows...
	call Keys_ProcessRow
	ENDM
Keys_Scan_updateLast:
	ld hl,NEWKEY
	ld de,Keys_lastScan
	REPT 11
	ldi
	ENDM
	ret

Keys_ProcessRow:
	ld b,8
	ld a,(de)
	ld c,(hl)
	xor c
Keys_ProcessRow_loop:
	rrc c
	rrca       ; preserves sign flag
	call c,Keys_ProcessRowPress
	inc ix
	djnz Keys_ProcessRow_loop
	inc de
	inc hl
	ret

Keys_ProcessRowPress:
	jp p,Keys_ProcessRowRelease
	push af
	ld a,(ix)
	and a
	jp p,Keys_ProcessRowPress_note
	cp -2
	jp z,Keys_ProcessRowPress_increaseVelocity
	cp -3
	jp z,Keys_ProcessRowPress_decreaseVelocity
	pop af
	ret

Keys_ProcessRowRelease:
	push af
	ld a,(ix)
	and a
	jp p,Keys_ProcessRowRelease_note
	pop af
	ret

Keys_ProcessRowPress_note:
	push bc
	push de
	push hl
	push ix
	ld bc,(Keys_velocity)
	call SCC_NoteOn
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	ret

Keys_ProcessRowRelease_note:
	push bc
	push de
	push hl
	push ix
	ld bc,4000H
	call SCC_NoteOff
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	ret

Keys_ProcessRowPress_increaseVelocity:
	ld a,(Keys_velocity + 1)
	add a,8
	and 7FH
	ld (Keys_velocity + 1),a
	pop af
	ret

Keys_ProcessRowPress_decreaseVelocity:
	ld a,(Keys_velocity + 1)
	sub 8
	and 7FH
	ld (Keys_velocity + 1),a
	pop af
	ret

Keys_noteMapping:
	db 63, -1, 49, 51, -1, 54, 56, 58  ; row 0: 0 1 2 3 4 5 6 7
	db -1, 61, -1, 66, 68, 65, 67, 75  ; row 1: 8 9 - = \ [ ] ;
	db -1, -1, 72, 74, 76, -1, -1, 67  ; row 2: ' ` , . / DEAD A B
	db 64, 63, 52, -1, 66, 68, 60, 70  ; row 3: C D E F G H I J
	db -1, 73, 71, 69, 62, 64, 48, 53  ; row 4: K L M N O P Q R
	db 61, 55, 59, 65, 50, 62, 57, 60  ; row 4: S T U V W X Y Z
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: SHIFT CTRL GRAPH CAPS CODE F1 F2 F3
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: F4 F5 ESC TAB STOP BS SELECT RET
	db -1, -1, -1, -1, -1, -2, -3, -1  ; row 4: SPACE HOME INS DEL ← ↑ ↓ →
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: NUM* NUM+ NUM/ NUM0 NUM1 NUM2 NUM3 NUM4
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: NUM5 NUM6 NUM7 NUM8 NUM9 NUM- NUM, NUM.
