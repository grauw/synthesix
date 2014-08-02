/*
 * Tests efficient fraction multiplication by just adding / shifting in an 8-bit
 * register. There is also a second algorithm with different value distribution.
 */

for (var a = 0; a < 256; a++) {
	multAll(a, true);
}

function multAll(a, debug) {
	var arr = [];
	for (var b = 0; b < 256; b++)
		arr.push(multSigned(a, b));
	if (debug) {
		console.log("Multiplying " + a + ":");
		for (var l = 0; l < arr.length; l += 16)
			console.log("\t" + arr.slice(l, l + 16).join(", "));
	}
	return arr;
}

/**
 * Handles multiplications with negative (1’s complement) values.
 */
function multSigned(a, b, debug) {
	if (b >= 128)
		return 255 - multSigned(a, 255 - b, debug);
	if (a >= 128)
		return 255 - multSigned(255 - a, b, debug);
	return mult(a, b, debug);
}

/**
 * This multiplication rounds values.
 */
function mult(a, b, debug) {
	var v = a >> 1;
	for (var i = 0; i < 7; i++) {
		if ((b >> i) & 1 == 1)
			v += a;
		if (debug)
			console.log(i + ": " + v);
		var rounding = v & 1;
		v = v >> 1;
	}
	return v + rounding;
}

/**
 * This multiplication evenly distributes the value space.
 * When multiplying two, values 0, 1 and 2 will all have 1/3rd of the results.
 * In other words, floored multiplication with a + 1.
 */
function mult_distribute(a, b, debug) {
	a++;
	var v = a >> 1;
	for (var i = 0; i < 7; i++) {
		if ((b >> i) & 1 == 1)
			v += a;
		if (debug)
			console.log(i + ": " + v);
		v = v >> 1;
	}
	return v;
}
