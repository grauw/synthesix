var clock = 3579545;  // hz

for (var note = 0; note < 128; note++) {
	var frequency = 440 * Math.pow(2, (note - 69) / 12);
	var registerValue = Math.round(clock / frequency / 256 - 1);
	console.log("\tdw " + registerValue + "  ; note " + note);
}
