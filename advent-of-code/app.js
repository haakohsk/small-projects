// task 1, day one
// see https://adventofcode.com/2021 for task descriptions
let count = 0;
for(let i = 1; i < input.length; i++) {
    if (input[i] > input[i - 1]) {
        count++;
    }  
}
console.log(count);

// task 2, day one
let count2 = 0;
let data = input[0] + input[1] + input[2];
for(let j = 1; j < input.length - 2; j++) {
    if (input[j]+input[j+1]+input[j+2] > data) {
        count2++;
    }
    data = input[j] + input[j+1] + input[j+2];
}    
console.log(count2);