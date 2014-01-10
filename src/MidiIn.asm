;
; MIDI in
;

; z = a message can be read
; Modifies: af, hl
MidiIn_HasMessage:
	ld hl,(MidiIn_bufferHead)
	ld a,(MidiIn_bufferTail)
	cp l
	ret

; a = byte
; f <- z: buffer full
; Modifies: af, hl
MidiIn_WriteByte:
	ld hl,(MidiIn_bufferHead)
	ld (hl),a
	inc l
	ld (MidiIn_bufferHead),hl
	ld a,(MidiIn_bufferTail)
	cp l
	ret

; a <- byte
; f <- z: buffer empty
; Modifies: af, hl
MidiIn_ReadByte:
	ld hl,(MidiIn_bufferTail)
	ld a,(MidiIn_bufferHead)
	cp l
	ret z
	ld a,(hl)
	inc l
	ld (MidiIn_bufferTail),hl
	ret

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

; a = channel
; b = program
MidiIn_ProgramChange:
	or 11000000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ret

; a = channel
; b = pressure
MidiIn_ChannelPressure:
	or 11010000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ret

; a = channel
; b = coarse
; c = fine
MidiIn_PitchBend:
	or 11100000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ret

;
; Modifies: af, af', bc, hl
MidiIn_ProcessMessages: PROC
	ld hl,(MidiIn_bufferTail)
	ld a,(MidiIn_bufferHead)
	sub l
	ret z  ; no messages
	ex af,af'
	ld a,(hl)
	add a,a
	jp nc,ProcessRunningStatus
	inc l
	ld (MidiIn_runningStatus),a
ProcessStatus_1:
	add a,a
	jp c,ProcessStatus_11
ProcessStatus_10:
	add a,a
	jp c,ProcessStatus_101
ProcessStatus_100:
	add a,a
	jp c,ProcessStatus_1001
ProcessStatus_1000:
	call_channel 3, Channel_NoteOff
ProcessStatus_1001:
	call_channel 3, Channel_NoteOn
ProcessStatus_101:
	add a,a
	jp c,ProcessStatus_1011
ProcessStatus_1010:
	call_channel 3, Channel_PolyPressure
ProcessStatus_1011:
	call_channel 3, Channel_ControlChange
ProcessStatus_11:
	add a,a
	jp c,ProcessStatus_111
ProcessStatus_110:
	add a,a
	jp c,ProcessStatus_1101
ProcessStatus_1100:
	call_channel 2, Channel_ProgramChange
ProcessStatus_1101:
	call_channel 2, Channel_ChannelPressure
ProcessStatus_111:
	add a,a
	jp c,ProcessStatus_1111
ProcessStatus_1110:
	call_channel 3, Channel_PitchBend
ProcessStatus_1111:
	ex af,af'
	cp 0FFH
	ret nc
	ld a,(hl)
	and a
	jp m,ProcessStatus_1111_NoInc
	inc l  ; only increase if it is a data byte
ProcessStatus_1111_NoInc:
	ld (MidiIn_bufferTail),hl
	ret

ProcessRunningStatus:
	ex af,af'
	dec a
	ex af,af'
	ld a,(MidiIn_runningStatus)
	add a,a
	cp 0ECH  ;0F6H
	jp c,ProcessStatus_1
	inc l  ; if a status which does not have data bytes, skip data byte
	ld (MidiIn_bufferTail),hl
	jp MidiIn_ProcessMessages

call_channel: MACRO ?length, ?method
	ex af,af'
	cp 0FFH - ?length
	ret nc  ; message incomplete
	ex af,af'
	ld b,(hl)
	inc l
	IF ?length = 3
	ld c,(hl)
	inc l
	ENDIF
	ld (MidiIn_bufferTail),hl
	rrca
	rrca
	rrca
	add a,Channel_channels & 0FFH
	ld l,a
	ld h,Channel_channels >> 8
	ld a,(hl)
	ld ixl,a
	inc l
	ld a,(hl)
	ld ixh,a
	IF ?length = 2
	ld a,b
	ELSE
	ld a,c
	ENDIF
	or b
	jp m,NotADataByte
	call ?method
	jp MidiIn_ProcessMessages  ; next message
	ENDM

; if value is out of bounds, skip it
NotADataByte:
	dec l
	ld (MidiIn_bufferTail),hl
	bit 7,b
	jp z,MidiIn_ProcessMessages
	dec l
	ld (MidiIn_bufferTail),hl
	jp MidiIn_ProcessMessages
	ENDP

;
	SECTION RAM

MidiIn_runningStatus:
	db 0FEH

MidiIn_bufferHead:
	dw MidiIn_buffer
MidiIn_bufferTail:
	dw MidiIn_buffer

	ALIGN 100H
MidiIn_buffer:
	ds 256, 0FEH

	ENDS
