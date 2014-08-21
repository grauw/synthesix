ControllerBank: MACRO
	outputs:
	controllers:
		Value 0  ; 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 100
		Value 0  ; 8
		Value 0
		Value 64
		Value 127
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 16
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 24
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 32
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 40
		Value 0
		Value 0
		Value 127
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 48
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 56
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 64
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 72
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 80
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 88
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 96
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 104
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 112
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
	outputsEnd:
	inputs:
	inputsEnd:
	labels: equ ControllerBank_labels
	_size:
	ENDM

	dw ControllerBank._size
ControllerBank_class: ControllerBank

; ix, de <- new object
ControllerBank_New:
	ld iy,ControllerBank_class
	call Class_New
	jp ControllerBank_Constructor

; ix = this
; ix, de <- this
ControllerBank_Constructor:
	ld e,ixl
	ld d,ixh
	ret

; de = this
; hl <- controller value address
ControllerBank_GetController:
	ld l,a
	ld h,0
	add hl,de
	ret

; de = this
ControllerBank_Reset:
	ld hl,ControllerBank_class
	ld bc,ControllerBank._size
	ldir
	ret

;
ControllerBank_labels:
	db "Controllers",0
	db "Bank C",0
	db "Mod",0
	db "Breath",0
	db "CC# 4",0
	db "Foot",0
	db "P.Time",0
	db "Data C",0
	db "Volume",0
	db "Balance",0
	db "CC# 9",0
	db "Pan",0
	db "Expression",0
	db "Fx 1",0
	db "Fx 2",0
	db "CC# 14",0
	db "CC# 15",0
	db "CC# 16",0
	db "CC# 17",0
	db "CC# 18",0
	db "CC# 19",0
	db "CC# 20",0
	db "CC# 21",0
	db "CC# 22",0
	db "CC# 23",0
	db "CC# 24",0
	db "CC# 25",0
	db "CC# 26",0
	db "CC# 27",0
	db "CC# 28",0
	db "CC# 29",0
	db "CC# 30",0
	db "CC# 31",0
	db "CC# 32",0
	db "CC# 33",0
	db "CC# 34",0
	db "CC# 35",0
	db "CC# 36",0
	db "CC# 37",0
	db "CC# 38",0
	db "CC# 39",0
	db "CC# 40",0
	db "CC# 41",0
	db "CC# 42",0
	db "CC# 43",0
	db "CC# 44",0
	db "CC# 45",0
	db "CC# 46",0
	db "CC# 47",0
	db "CC# 48",0
	db "CC# 49",0
	db "CC# 50",0
	db "CC# 51",0
	db "CC# 52",0
	db "CC# 53",0
	db "CC# 54",0
	db "CC# 55",0
	db "CC# 56",0
	db "CC# 57",0
	db "CC# 58",0
	db "CC# 59",0
	db "CC# 60",0
	db "CC# 61",0
	db "CC# 62",0
	db "CC# 63",0
	db "Sustain",0
	db "CC# 65",0
	db "CC# 66",0
	db "CC# 67",0
	db "CC# 68",0
	db "CC# 69",0
	db "CC# 70",0
	db "CC# 71",0
	db "CC# 72",0
	db "CC# 73",0
	db "CC# 74",0
	db "CC# 75",0
	db "CC# 76",0
	db "CC# 77",0
	db "CC# 78",0
	db "CC# 79",0
	db "CC# 80",0
	db "CC# 81",0
	db "CC# 82",0
	db "CC# 83",0
	db "CC# 84",0
	db "CC# 85",0
	db "CC# 86",0
	db "CC# 87",0
	db "CC# 88",0
	db "CC# 89",0
	db "CC# 90",0
	db "CC# 91",0
	db "CC# 92",0
	db "CC# 93",0
	db "CC# 94",0
	db "CC# 95",0
	db "CC# 96",0
	db "CC# 97",0
	db "CC# 98",0
	db "CC# 99",0
	db "CC# 100",0
	db "CC# 101",0
	db "CC# 102",0
	db "CC# 103",0
	db "CC# 104",0
	db "CC# 105",0
	db "CC# 106",0
	db "CC# 107",0
	db "CC# 108",0
	db "CC# 109",0
	db "CC# 110",0
	db "CC# 111",0
	db "CC# 112",0
	db "CC# 113",0
	db "CC# 114",0
	db "CC# 115",0
	db "CC# 116",0
	db "CC# 117",0
	db "CC# 118",0
	db "CC# 119",0
