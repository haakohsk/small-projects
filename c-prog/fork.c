#include <stdio.h>
#include <unistd.h>

int main(void) {
	
	int p, i = 0;
	for(i = 0; i < 5; i++) {
		p = fork();
	if (p==0) {
		printf("Hi, I'm a child process with PID %i\n", getpid());
		return 0;
	}
	sleep(1);
	}
	return 0;
}
