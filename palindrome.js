palindromeChecker = (word) => {
    let input = 'racecar'; // insert word for check
    let string = word.split('').reverse().join('');

    if (string == input) {
        console.log('Is an palindrome');
        return true;
    } else {
        console.log('Not a palindrome')
        return false;
    }
}

console.log(
    palindromeChecker('racecar') // insert words for palindrome check
);
