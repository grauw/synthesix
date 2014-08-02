/*
 * An experiment of multiplication arithmetic.
 * This experiment kind of failed, as the values are not nicely distributed.
 * See output of value 47.
 */

function mult(a, b) {
	var v = 0;
	for (var i = 1; i < 8; i++)
		v += a & (1 << (7 - i)) ? (b >> i) + ((b >> (i - 1)) & 1) : 0;
	return v;
}

function multAll(b) {
	var arr = [];
	for (var a = 0; a < 128; a++)
		arr.push(mult(a, b));
	return arr;
}

console.log(multAll(47).join(", "));

/*
	add a,a
	sra b
	jr c,skip1
	adc a,b
skip1:
	add a,a
	sra b
	jr c,skip2
	adc a,b
skip2:
	;...
*/
