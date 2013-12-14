all:
	pasmo -I src src/ram.asm gen/ram.bin gen/ram.symbol
	pasmo -I src -I gen src/rom.asm bin/synthe6.rom

run: all
	openmsx -cart bin/synthe6.rom -romtype KonamiSCC -machine Panasonic_FS-A1GT
