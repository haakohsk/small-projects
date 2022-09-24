// import & handle txt input
const fs = require("fs")
const path = require("path")
const inputtxt = fs
	.readFileSync(path.join(__dirname, 'day2-input.txt'), 'utf8')
	.toString()
	.trim()
	.split('\n')
	.map((line) => {
		let [movement, amount] = line.split(' ');
		amount = parseInt(amount, 10);

		return {
			movement,
			amount,
		};
	});


// task 1, day two     
let x = 0;
let y = 0;

for (let { movement, amount } of inputtxt) {
	if (movement === 'up') {
		y -= amount;
	} else if (movement === 'down') {
		y += amount;
	} else if (movement === 'forward') {
		x += amount;
	} else {
        // error?
		throw new Error(`Unknown movement: ${movement}`);
	}
}

console.log(y * x);

// task 2, day two

let aim = 0;

for (let { movement, amount } of inputtxt) {
	if (movement === 'up') {
		aim -= amount;
	} else if (movement === 'down') {
		aim += amount;
	} else if (movement === 'forward') {
		x += amount;
		y += aim * amount;
	} else {
		// throw new Error(`Unknown movement: ${mvmnt}`);
	}
}

console.log(y * x);