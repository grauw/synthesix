/*
 * Given a mix value 0 - 128, outputs how many parts of a and b are added.
 * Additionally it outputs the common divider, which means less shifts are
 * needed to multiply certain values. This is informative. E.g.:
 *
 * mix_64:
 *     ld a,b
 *     add a,c
 *     rra
 *     ret
 *
 * mix_32:
 *     ld a,b
 *     add a,c
 *     rra
 *     add a,b
 *     rra
 *     ret
 */

checkCommonDivider();

function checkCommonDivider() {
	for (var i = 0; i <= 128; i++) {
		var a = 128 - i, b = i;
		for (var j = i + 1; j > 0; j--) {
			if (a % j == 0 && b % j == 0) {
				console.log("mix " + i + ": " + a + " parts a / " + b +
						" parts b -> divider: " + j + ", a: " +
						(a/j).toString(2) + ", b: " + (b/j).toString(2));
				break;
			}
		}
	}
}
