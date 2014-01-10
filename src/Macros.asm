;
; Pads up to a certain address
; Gives an error message if that address is already exceeded.
;
PAD: MACRO ?address
	IF $ > ?address
		ERROR "Alignment exceeds %s"; % ?address
	ENDIF
	ds ?address - $
	ENDM

;
; Pads up to the next multiple of the specified address.
;
ALIGN: MACRO ?boundary
	ds ?boundary - 1 - ($ + ?boundary - 1) % ?boundary
	ENDM
