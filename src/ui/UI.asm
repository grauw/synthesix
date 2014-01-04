UI_Init:
	call VDP_InitScreen0
	call VDP_Enable212Lines
	ld a,0
	ld hl,0
	call VDP_SetWriteAddress
	ld hl,UI_template
	ld bc,UI_template_size
	call VDP_Write
	ret

UI_Update:
	call UI_UpdateLiveIndicator
	ret

UI_UpdateLiveIndicator:
	ld a,0
	ld hl,47
	call VDP_SetWriteAddress
	ld a,(JIFFY)
	bit 5,a
	ld a,'x'
	jr z,UI_UpdateLiveIndicator_Tock
	ld a,'X'
UI_UpdateLiveIndicator_Tock:
	out (VDP_PORT_0),a
	ret

;
UI_template:
	db 24,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23
	db " S y n t h e s i x "
	db 23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,25
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 20,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23
	db 23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,19
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23
	db 23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
UI_template_size: equ $ - UI_template
