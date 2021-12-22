anagramChecker = (wordA, wordB) => {
    // check for same length
    if (wordA.length !== wordB.length) {
        console.log('Not an anagram, words are not the same length') 
        return false;
    } 

    // split parses all word into chars in array, sort() sorts in correct order
    // join() makes array into string again, but in correct order 
    let string1 = wordA.split('').sort().join('');
    let string2 = wordB.split('').sort().join('');

    if (string1 == string2) {
        console.log('Is an anagram');
        return true;
    } else {
        console.log('Not an anagram, same length, but all characters do not match')
        return false;
    }
}

console.log(
    anagramChecker('test', 'tets') // insert words for anagram check
);






