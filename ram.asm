;
; All RAM data is defined below
; These values are copied to RAM during program initialisation
;

	org 0C000H
ram_data_start_address:

keys_last_scan:
	ds 11,0
