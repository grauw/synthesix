var arr = [];
for (var i = 0; i < 128; i++) {
	for (var j = 0; j < 128; j++) {
		arr.push(Math.round(i * j / 127));
	}
}

for (var i = 0; i < arr.length; i += 16) {
	if (i % 128 == 0)
		console.log("\t; " + i / 128);
	console.log("\tdb " + arr.slice(i, i + 16).join(", "));
}
