Keys_Init:
	ld a,0
	ld (CLIKSW),a  ; disable key click
	ld hl,NEWKEY
	ld de,Keys_lastScan
	ld bc,11
	ldir
	ret

Keys_Scan:
	ld hl,Keys_lastScan
	ld de,Keys_noteMapping
	REPT 11, ?row
	ld b,?row
	call Keys_ProcessRow
	ENDM
	ret

Keys_ProcessRow:
	di
	in a,(PPI_PORT_C)
	and 11110000B
	or b
	out (PPI_PORT_C),a
	ei
	in a,(PPI_PORT_B)
	ld c,(hl)
	ld (hl),a
	inc hl
	xor c
	jr z,Keys_ProcessRow_NoChange
	ld b,8
Keys_ProcessRow_Loop:
	rrc c
	rrca       ; preserves sign flag
	jp nc,Keys_ProcessRow_Next
	push af
	push bc
	push de
	push hl
	ld a,(de)
	call Keys_ProcessKeyChange
	pop hl
	pop de
	pop bc
	pop af
Keys_ProcessRow_Next:
	inc de
	djnz Keys_ProcessRow_Loop
	ret
Keys_ProcessRow_NoChange:
	ld a,e
	add a,8
	ld e,a
	ret nc
	inc d
	ret

; a = key / note identifier
; f = negative sign: press, positive sign: release
Keys_ProcessKeyChange:
	jp p,Keys_ProcessKeyRelease
	jp Keys_ProcessKeyPress

; a = key / note identifier
Keys_ProcessKeyPress:
	and a
	jp p,Keys_PressNote
	cp -2
	jp z,Keys_PressIncreaseVelocity
	cp -3
	jp z,Keys_PressDecreaseVelocity
	cp -4
	jp z,Keys_PressIncreaseModulation
	cp -5
	jp z,Keys_PressDecreaseModulation
	cp -99
	jp z,Keys_PressEscape
	ret

; a = key / note identifier
Keys_ProcessKeyRelease:
	and a
	jp p,Keys_ReleaseNote
	ret

Keys_PressNote:
	ld b,a
	ld a,(Keys_velocity)
	ld c,a
	ld a,0
	call MidiIn_NoteOn
	ret

Keys_ReleaseNote:
	ld b,a
	ld c,40H
	ld a,0
	call MidiIn_NoteOff
	ret

Keys_PressIncreaseVelocity:
	ld a,(Keys_velocity)
	add a,8
	and 7FH
	ld (Keys_velocity),a
	ret

Keys_PressDecreaseVelocity:
	ld a,(Keys_velocity)
	sub 8
	and 7FH
	ld (Keys_velocity),a
	ret

Keys_PressIncreaseModulation:
	ld a,(Keys_modulation)
	inc a
	and 7FH
	ld (Keys_modulation),a
	ld b,1
	ld c,a
	ld a,0
	call MidiIn_ControlChange
	ret

Keys_PressDecreaseModulation:
	ld a,(Keys_modulation)
	dec a
	and 7FH
	ld (Keys_modulation),a
	ld b,1
	ld c,a
	ld a,0
	call MidiIn_ControlChange
	ret

Keys_PressEscape:
	ld a,-1
	ld (Keys_escape),a
	ret

Keys_noteMapping:
	db 63, -1, 49, 51, -1, 54, 56, 58  ; row 0: 0 1 2 3 4 5 6 7
	db -1, 61, -1, 66, 68, 65, 67, 75  ; row 1: 8 9 - = \ [ ] ;
	db -1, -1, 72, 74, 76, -1, -1, 67  ; row 2: ' ` , . / DEAD A B
	db 64, 63, 52, -1, 66, 68, 60, 70  ; row 3: C D E F G H I J
	db -1, 73, 71, 69, 62, 64, 48, 53  ; row 4: K L M N O P Q R
	db 61, 55, 59, 65, 50, 62, 57, 60  ; row 4: S T U V W X Y Z
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: SHIFT CTRL GRAPH CAPS CODE F1 F2 F3
	db -1, -1,-99, -1, -1, -1, -1, -1  ; row 4: F4 F5 ESC TAB STOP BS SELECT RET
	db -1, -1, -1, -1, -5, -2, -3, -4  ; row 4: SPACE HOME INS DEL ← ↑ ↓ →
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: NUM* NUM+ NUM/ NUM0 NUM1 NUM2 NUM3 NUM4
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: NUM5 NUM6 NUM7 NUM8 NUM9 NUM- NUM, NUM.

;
; Variables in RAM
;
	SECTION RAM

Keys_lastScan:
	ds 11,0

Keys_velocity:
	db 7FH

Keys_modulation:
	db 00H

Keys_escape:
	db 0

	ENDS
