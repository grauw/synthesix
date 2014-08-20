;
; Keyboard MIDI
;
; And other key handling.
;
KeyMidi: MACRO
	super: MidiIn MidiIn_buffer1
	lastScan:
		ds 11,0
	keyBufferHead:
		dw KeyMidi_keyBuffer
	keyBufferTail:
		dw KeyMidi_keyBuffer
	repeat:
		db 0
	velocity:
		db 7FH
	quit:
		db 0
	shift:
		db 0
	ENDM

; ix = this
KeyMidi_Constructor:
	ld a,0
	ld (CLIKSW),a  ; disable key click
	ld e,ixl
	ld d,ixh
	ld hl,KeyMidi.lastScan
	add hl,de
	ex de,hl
	ld hl,NEWKEY
	ld bc,11
	ldir
	ret

; ix = this
; a = byte
; f <- z: buffer full
; Modifies: af, hl
KeyMidi_WriteKeyCode:
	ld l,(ix + KeyMidi.keyBufferHead)
	ld h,(ix + KeyMidi.keyBufferHead + 1)
	ld (hl),a
	inc l
	ld (ix + KeyMidi.keyBufferHead),l
	ld a,(ix + KeyMidi.keyBufferTail)
	cp l
	ret nz
	call System_ThrowException
	ret

; ix = this
; a <- byte
; f <- z: buffer empty
; Modifies: af, hl
KeyMidi_ReadKeyCode:
	ld l,(ix + KeyMidi.keyBufferTail)
	ld h,(ix + KeyMidi.keyBufferTail + 1)
	ld a,(ix + KeyMidi.keyBufferHead)
	cp l
	ret z
	ld a,(hl)
	inc l
	ld (ix + KeyMidi.keyBufferTail),l
	ret

; ix = this
KeyMidi_Scan:
	ld e,ixl
	ld d,ixh
	ld hl,KeyMidi.lastScan
	add hl,de
	ld de,KeyMidi_noteMapping
	REPT 11, ?row
	ld b,?row
	call KeyMidi_ProcessRow
	ENDM
	ld a,(ix + KeyMidi.repeat)
	and a
	ret z
	dec (ix + KeyMidi.repeat)
	ret nz
	ld bc,11
	sbc hl,bc
	ld de,KeyMidi_noteMapping
	REPT 11, ?row
	call KeyMidi_ProcessRowRepeat
	ENDM
	ret

; b = row number
; hl = last scan buffer (indexed)
; de = note mapping table (indexed)
; ix = this
KeyMidi_ProcessRow: PROC
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
	jr z,NoChange
	ld b,8
Loop:
	rrc c
	rrca       ; preserves sign flag
	jp nc,Next
	push af
	push bc
	push de
	push hl
	push ix
	ld a,(de)
	call KeyMidi_ProcessKeyChange
	pop ix
	pop hl
	pop de
	pop bc
	pop af
Next:
	inc de
	djnz Loop
	ret
NoChange:
	ld a,e
	add a,8
	ld e,a
	ret nc
	inc d
	ret
	ENDP

; hl = last scan buffer (indexed)
; de = note mapping table (indexed)
; ix = this
KeyMidi_ProcessRowRepeat: PROC
	ld a,(hl)
	inc hl
	inc a
	jr z,NothingPressed
	dec a
	ld b,8
Loop:
	rrca       ; preserves sign flag
	jp c,Next
	push af
	push bc
	push de
	push hl
	push ix
	ld a,(de)
	call KeyMidi_ProcessKeyRepeat
	pop ix
	pop hl
	pop de
	pop bc
	pop af
Next:
	inc de
	djnz Loop
	ret
NothingPressed:
	ld a,e
	add a,8
	ld e,a
	ret nc
	inc d
	ret
	ENDP

; ix = this
; a = key / note identifier
; f = negative sign: press, positive sign: release
KeyMidi_ProcessKeyChange:
	jp p,KeyMidi_ProcessKeyRelease
	jp KeyMidi_ProcessKeyPress

; ix = this
; a = key / note identifier
KeyMidi_ProcessKeyPress:
	and a
	jp m,KeyMidi_PressNote
	cp 1
	jp z,KeyMidi_PressSpace
	cp 2
	jp z,KeyMidi_PressQuit
	cp 3
	jp z,KeyMidi_PressShift
	cp 4
	jp z,KeyMidi_PressF4
	cp 5
	jp z,KeyMidi_PressF5
	cp 0
	jp nz,KeyMidi_KeyCodePress
	ret

; ix = this
; a = key / note identifier
KeyMidi_ProcessKeyRelease:
	and a
	jp m,KeyMidi_ReleaseNote
	cp 1
	jp z,KeyMidi_ReleaseSpace
	cp 3
	jp z,KeyMidi_ReleaseShift
	ret

; ix = this
; a = key / note identifier
KeyMidi_ProcessKeyRepeat:
	and a
	ret m
	cp 8
	jp nc,KeyMidi_KeyCodeRepeat
	ret

; ix = this
; a = note number (negated)
KeyMidi_PressNote:
	neg
	ld b,a
	ld a,(ix + KeyMidi.velocity)
	ld c,a
	ld a,0
	call MidiIn_NoteOn
	ret

; ix = this
; a = note number (negated)
KeyMidi_ReleaseNote:
	neg
	ld b,a
	ld c,40H
	ld a,0
	call MidiIn_NoteOff
	ret

; ix = this
; a = key code
KeyMidi_KeyCodePress:
	call KeyMidi_WriteKeyCode
	ld (ix + KeyMidi.repeat),30 + 1
	ret

; ix = this
; a = key code
KeyMidi_KeyCodeRepeat:
	call KeyMidi_WriteKeyCode
	ld (ix + KeyMidi.repeat),3 + 1
	ret

; ix = this
KeyMidi_PressQuit:
	ld a,-1
	ld (ix + KeyMidi.quit),a
	ret

; ix = this
KeyMidi_PressShift:
	ld a,-1
	ld (ix + KeyMidi.shift),a
	ret

; ix = this
KeyMidi_ReleaseShift:
	ld a,0
	ld (ix + KeyMidi.shift),a
	ret

; ix = this
KeyMidi_PressSpace:
	ld b,1
	ld c,7FH
	ld a,0
	call MidiIn_ControlChange
	ret

; ix = this
KeyMidi_ReleaseSpace:
	ld b,1
	ld c,0
	ld a,0
	call MidiIn_ControlChange
	ret

; ix = this
KeyMidi_PressF4:
	bit 7,(ix + KeyMidi.shift)
	ret z
	ld b,121  ; all controllers off
	ld c,0
	ld a,0
	call MidiIn_ControlChange
	ret

; ix = this
KeyMidi_PressF5:
	bit 7,(ix + KeyMidi.shift)
	ret z
	ld b,123  ; all notes off
	ld c,0
	ld a,0
	call MidiIn_ControlChange
	ret

KeyMidi_noteMapping:
	db  -75,   0, -61, -63,   0, -66, -68, -70  ; row 0: 0 1 2 3 4 5 6 7
	db    0, -73,   0, -78, -56, -77, -79, -63  ; row 1: 8 9 - = \ [ ] ;
	db    0,   0,  60, -62, -64,   0,   0, -55  ; row 2: ' ` , . / DEAD A B
	db  -52, -51, -64,   0, -54, -56, -72, -58  ; row 3: C D E F G H I J
	db    0, -61, -59, -57, -74, -76, -60, -65  ; row 4: K L M N O P Q R
	db  -49, -67, -71, -53, -62, -50, -69, -48  ; row 5: S T U V W X Y Z
	db    3,   0,   0,   0,   0,   0,   0,   0  ; row 6: SHIFT CTRL GRAPH CAPS CODE F1 F2 F3
	db    4,   5,  27,   9,   2,   8,  24,  13  ; row 7: F4 F5 ESC TAB STOP BS SELECT RET
	db    1,  11,  18, 127,  29,  30,  31,  28  ; row 8: SPACE HOME INS DEL ← ↑ ↓ →
	db    0,   0,   0,   0,   0,   0,   0,   0  ; row 9: NUM* NUM+ NUM/ NUM0 NUM1 NUM2 NUM3 NUM4
	db    0,   0,   0,   0,   0,   0,   0,   0  ; row A: NUM5 NUM6 NUM7 NUM8 NUM9 NUM- NUM, NUM.

;
; Variables in RAM
;
	SECTION RAM

KeyMidi_instance: KeyMidi

	ALIGN 100H
KeyMidi_keyBuffer:
	ds 256

	ENDS
