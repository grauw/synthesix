/*
 * Tests efficient mixing using just adding / shifting in an 8-bit register.
 * Change mixer_round in the for loop below to test the other strategies.
 * This so that a mixing code table could be generated.
 *
 * Note that for efficiency, a + mix * (b - a) may also be a possible approach. 
 */

for (var a = 0; a < 128; a++) {
	mixAll(a, 0, mixer_round, true);
}

function mixAll(a, b, mixer, debug) {
	var arr = [];
	for (var mix = 0; mix < 128; mix++)
		arr.push(mixer(a, b, mix));
	if (debug) {
		console.log("Mixing " + a + ":");
		for (var l = 0; l < arr.length; l += 16)
			console.log("\t" + arr.slice(l, l + 16).join(", "));
	}
	return arr;
}

/**
 * This mixer rounds values.
 * See mixAll(2, 0, mixer_round, true).
 */
function mixer_round(a, b, mix, debug) {
	var v = a >> 1;
	for (var i = 0; i < 7; i++) {
		if ((mix >> i) & 1)
			v += b;
		else
			v += a;
		if (debug)
			console.log(i + ": " + v);
		var rounding = v & 1;
		v = v >> 1;
	}
	return v + rounding;
}

/**
 * This mixer floors values exclusively, 0..127 = [0..1).
 * See mixAll(3, 0, mixer_floor, true).
 */
function mixer_floor(a, b, mix, debug) {
	var v = a;
	for (var i = 0; i < 7; i++) {
		if ((mix >> i) & 1)
			v += b;
		else
			v += a;
		if (debug)
			console.log(i + ": " + v);
		v = v >> 1;
	}
	return v;
}

/**
 * This mixer ceils values exclusively, 0..127 = [0..1).
 * See mixAll(4, 0, mixer_ceil, true).
 */
function mixer_ceil(a, b, mix, debug) {
	var v = a;
	for (var i = 0; i < 7; i++) {
		if ((mix >> i) & 1)
			v += b;
		else
			v += a;
		if (debug)
			console.log(i + ": " + v);
		v = (v >> 1) + (v & 1);
	}
	return v;
}

/**
 * This mixer is a bit of a failure. Between mixing downwards and upwards, it is
 * inconsistent in how it rounds and whether or not it is actually inclusive.
 * As such the reverse does not match and it is not suitable for interpolation.
 * However, the downward range code path could be useful for multiplication,
 * because it distributes the values evenly (rather than rounding).
 * See mixAll(3, 0, mixer_inclusive, true).
 */
function mixer_inclusive(a, b, mix, debug) {
	a++;
	var v = a >> 1;
	for (var i = 0; i < 7; i++) {
		if ((mix >> i) & 1)
			v += b;
		else
			v += a;
		if (debug)
			console.log(i + ": " + v);
		v = v >> 1;
	}
	return v;
}
