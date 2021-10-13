palindromeChecker = (word) => {
    // stores the reversed word in a variable 'reverseWord'
    let reverseWord = word.split('').reverse().join('');

    if (reverseWord == word) {
        console.log('Is a palindrome');
        return true;
    } else {
        console.log('Not a palindrome')
        return false;
    }
}

console.log(
    palindromeChecker('racecar') // insert words for palindrome check
);
