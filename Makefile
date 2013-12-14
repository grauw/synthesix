all:
	pasmo -I src src/rom.asm bin/synthe6.rom

run: all
	openmsx -cart bin/synthe6.rom -romtype KonamiSCC -machine Panasonic_FS-A1GT
