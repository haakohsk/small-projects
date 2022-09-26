const readline = require('readline').createInterface({
	input: process.stdin,
	output: process.stdout,
});

readline.question(`Test if a word is a palindrome: `, word => {
	console.log(`Your word is ${word}.`);
	readline.close();

	isPalidrome = () => {
		let string = word.split('').reverse().join('');
		if (string == word) {
			return true;
		} else {
			return false;
		}
	}

	console.log(
		isPalidrome()
	);
});


