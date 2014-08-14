console.log("SineBipolar_table:");
genBipolarTable();

function genBipolarTable() {
	var values = [];

	for (var i = 0; i < 128; i++) {
		var value = Math.round(Math.sin(i * Math.PI / 128) * 127);
		values.push(value);
	}

	for (var i = 0; i < 128; i++) {
		values.push(-1 - values[i]);
	}

	for (var i = 0; i < values.length; i += 16) {
		console.log("\tdb " + values.slice(i, i + 16).join(", "));
	}
}
