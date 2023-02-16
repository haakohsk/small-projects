#include <stdio.h>

int main() {
//    char variabel='A';
    char *variabel2="A";
    char *navn="123";
    char *navn2="123";
    printf("They are the same, lol...\n");

    if(navn==navn2) {
        printf("They are the same, lol...\n");
    } 
    printf("Dette er første char: %s\n", variabel2);
    printf("Dette er andre char: %p\n", navn);
    printf("Dette er siste char: %p\n", navn2);
    return 0;
}
