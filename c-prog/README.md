# C programming
## fork.c
- C-program that will fork five processes, with a one second sleep between each fork, where each of the five processes will say hello and print its process-ID.

## pthreads_test.c
- Program to visualize threads running in serial vs parallel.
- Compile with: `gcc pthreads_test.c -o pthreads_test -Wall -lm`
- Example run: `./pthreads_test serial 4` or `./pthreads_test parallel 4`
