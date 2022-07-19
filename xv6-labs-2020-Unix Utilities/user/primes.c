#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"


void sieve(int pleft[2]) { 
	int p;
	read(pleft[0], &p, sizeof(p)); 
	if(p == -1) { 
		exit(0);
	}
	printf("prime %d\n", p);

	int pright[2];
	pipe(pright); 

	if(fork() == 0) {
		close(pright[1]);
		close(pleft[0]); 
		sieve(pright); 

	} else {
		close(pright[0]); 
		int buf;
		while(read(pleft[0], &buf, sizeof(buf)) && buf != -1) { 
			if(buf % p != 0) { 
				write(pright[1], &buf, sizeof(buf));
			}
		}
		buf = -1;
		write(pright[1], &buf, sizeof(buf)); 
		wait(0); 
		exit(0);
	}
}

int main(int argc, char **argv) {
	int input_pipe[2];
	pipe(input_pipe); 

	if(fork() == 0) {
		close(input_pipe[1]);
		sieve(input_pipe);
		exit(0);
	} else {
		close(input_pipe[0]); 
		int i;
		for(i=2;i<=35;i++){ 
			write(input_pipe[1], &i, sizeof(i));
		}
		i = -1;
		write(input_pipe[1], &i, sizeof(i));
	}
	wait(0);
	exit(0);
}
