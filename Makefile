all:
	pasmo ram.asm ram.bin ram.symbol
	pasmo synthesix.asm synthe6.rom

run: all
	openmsx -cart synthe6.rom -romtype KonamiSCC -machine Panasonic_FS-A1GT
