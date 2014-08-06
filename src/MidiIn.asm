;
; MIDI in
;
MidiIn: MACRO ?buffer  ; buffer must be aligned to 100H
	bufferHead:
		dw ?buffer
	bufferTail:
		dw ?buffer
	runningStatus:
		db -1
	clock:
		db 0

	WriteByte: PROC
		cp 0F8H
		jr nc,RealTime
		ld hl,(bufferHead)
		ld (hl),a
		inc l
		ld (bufferHead),hl
		ld a,(bufferTail)
		cp l
		ret nz
		call System_ThrowException
	RealTime:
		ret nz  ; not clock
		ld hl,clock
		inc (hl)
		ret
		ENDP
	ENDM

; ix = this
; f <- nz: a message can be read
; Modifies: af
MidiIn_HasMessage:
	ld a,(ix + MidiIn.bufferHead)
	cp (ix + MidiIn.bufferTail)
	ret

; ix = this
; a = byte
; f <- z: buffer full
; Modifies: af, hl
MidiIn_WriteByte:
	cp 0F8H
	call nc,System_ThrowException
	ld l,(ix + MidiIn.bufferHead)
	ld h,(ix + MidiIn.bufferHead + 1)
	ld (hl),a
	inc l
	ld (ix + MidiIn.bufferHead),l
	ld a,(ix + MidiIn.bufferTail)
	cp l
	ret nz
	call System_ThrowException

; ix = this
; a <- byte
; f <- z: buffer empty
; Modifies: af, hl
MidiIn_ReadByte:
	ld l,(ix + MidiIn.bufferTail)
	ld h,(ix + MidiIn.bufferTail + 1)
	ld a,(ix + MidiIn.bufferHead)
	cp l
	ret z
	ld a,(hl)
	inc l
	ld (ix + MidiIn.bufferTail),l
	ret

; ix = this
; a = channel
; b = note
; c = velocity
MidiIn_NoteOff:
	or 10000000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ld a,c
	call MidiIn_WriteByte
	ret

; ix = this
; a = channel
; b = note
; c = velocity
MidiIn_NoteOn:
	or 10010000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ld a,c
	call MidiIn_WriteByte
	ret

; ix = this
; a = channel
; b = note
; c = pressure
MidiIn_PolyPressure:
	or 10100000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ld a,c
	call MidiIn_WriteByte
	ret

; ix = this
; a = channel
; b = controller
; c = value
MidiIn_ControlChange:
	or 10110000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ld a,c
	call MidiIn_WriteByte
	ret

; ix = this
; a = channel
; b = program
MidiIn_ProgramChange:
	or 11000000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ret

; ix = this
; a = channel
; b = pressure
MidiIn_ChannelPressure:
	or 11010000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ret

; ix = this
; a = channel
; b = coarse
; c = fine
MidiIn_PitchBend:
	or 11100000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ld a,c
	call MidiIn_WriteByte
	ret

; ix = this
; Modifies: af, af', bc, hl
MidiIn_ProcessMessages: PROC
	ld l,(ix + MidiIn.bufferTail)
	ld h,(ix + MidiIn.bufferTail + 1)
NextMessage:
	ld a,(ix + MidiIn.bufferHead)
	sub l
	ret z  ; no messages
	ld e,a
	ld a,(hl)
	inc l
	add a,a
	jp c,ProcessStatus_1
ProcessStatus_0:
	ld a,(ix + MidiIn.runningStatus)
	cp -1
	jp z,ProcessStatus_Skip
	dec l
	inc e
	jp ProcessStatus_1_Running
ProcessStatus_1:
	cp 0F0H << 1
	jr c,ProcessStatus_1_SetRunning
	cp 0F8H << 1
	jr nc,ProcessStatus_1_Running
	ld (ix + MidiIn.runningStatus),-1
	jp ProcessStatus_1_Running
ProcessStatus_1_SetRunning:
	ld (ix + MidiIn.runningStatus),a
ProcessStatus_1_Running:
	add a,a
	jp c,ProcessStatus_11
ProcessStatus_10:
	add a,a
	jp c,ProcessStatus_101
ProcessStatus_100:
	add a,a
	jp c,ProcessStatus_1001
ProcessStatus_1000:
	call_channel_3 Channel_NoteOff
ProcessStatus_1001:
	call_channel_3 Channel_NoteOn
ProcessStatus_101:
	add a,a
	jp c,ProcessStatus_1011
ProcessStatus_1010:
	call_channel_3 Channel_PolyPressure
ProcessStatus_1011:
	call_channel_3 Channel_ControlChange
ProcessStatus_11:
	add a,a
	jp c,ProcessStatus_111
ProcessStatus_110:
	add a,a
	jp c,ProcessStatus_1101
ProcessStatus_1100:
	call_channel_2 Channel_ProgramChange
ProcessStatus_1101:
	call_channel_2 Channel_ChannelPressure
ProcessStatus_111:
	add a,a
	jp c,ProcessStatus_1111
ProcessStatus_1110:
	call_channel_3 Channel_PitchBend
ProcessStatus_1111:
;	cp 0F4H << 4
;	jr nc,ProcessStatus_111100
	dec e
	ret z  ; message incomplete
	ld a,(hl)
	and a
	jp m,ProcessStatus_Skip
	inc l  ; only increase if it is a data byte
ProcessStatus_111100:
ProcessStatus_Skip:
	ld (ix + MidiIn.bufferTail),l
	jp NextMessage

call_channel_3: MACRO ?method
	dec e
	ret z  ; message incomplete
	dec e
	ret z  ; message incomplete
	push ix
	ld ixl,a
	ld ixh,Channel_channels >> 8
	ld b,(hl)
	inc l
	ld c,(hl)
	inc l
	ld a,b
	or c
	jp m,NotADataByte3
	push hl
	call ?method
	pop hl
	pop ix
	ld (ix + MidiIn.bufferTail),l
	jp NextMessage
	ENDM

call_channel_2: MACRO ?method
	dec e
	ret z  ; message incomplete
	push ix
	ld ixl,a
	ld ixh,Channel_channels >> 8
	ld a,(hl)
	and a
	jp m,NotADataByte
RunningStatus:
	inc l
	ld b,a
	dec e
	jr z,NoMoreData
	ld a,(hl)
	and a
	jp p,RunningStatus
NoMoreData:
	call ?method
NotADataByte:
	pop ix
	ld (ix + MidiIn.bufferTail),l
	jp NextMessage
	ENDM

; if a status byte is read where a data byte is expected, skip prev. message
NotADataByte3:
	pop ix
	dec l
	ld (ix + MidiIn.bufferTail),l
	bit 7,b
	jp z,NextMessage
	dec l
	ld (ix + MidiIn.bufferTail),l
	jp NextMessage
	ENDP

MidiIn_overrunErrorMessage:
	db "MIDI UART overrun error.",0

MidiIn_framingErrorMessage:
	db "MIDI UART framing error.",0

MidiIn_parityErrorMessage:
	db "MIDI UART parity error.",0

;
	SECTION RAM

	ALIGN 100H
MidiIn_buffer1:
	ds 100H, 0FEH
MidiIn_buffer2:
	ds 100H, 0FEH
MidiIn_buffer3:
	ds 100H, 0FEH
MidiIn_buffer4:
	ds 100H, 0FEH
MidiIn_buffer5:
	ds 100H, 0FEH

	ENDS
