#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
int main(int argc, char *argv[])
{
    if (argc > 1) {
	fprintf(2, "args ignored!\n");
    }

    int pp[2];
    int cp[2];
    pipe(pp);
    pipe(cp);

    char *p_write = "ping";
    char *c_write = "pong";
    int ret=fork();
    if (ret == 0) {
        close(pp[1]);
        close(cp[0]);
		int size = strlen(p_write) + 1;
		char buf[size];
		int n;
		while ((n = read(pp[0], buf, size)) > 0) {
            fprintf(1, "%d: received %s\n", getpid(), buf);
		}
        if (n < 0) {
            fprintf(2, "read error!\n");
            exit(1);
        }
        close(pp[0]);
        n = write(cp[1], c_write, strlen(c_write));
        close(cp[1]);
    } 
    else if (ret > 0) {
        // 同上
        close(pp[0]);
        close(cp[1]);
        int n = write(pp[1], p_write, strlen(p_write));
        close(pp[1]);
        int size = strlen(c_write) + 1;
        char buf[size];
        while ((n = read(cp[0], buf, size)) > 0) {
            fprintf(1, "%d: received %s\n", getpid(), buf);
        }
        n = read(cp[0], buf, size);
        if (n < 0) {
            fprintf(2, "read error!\n");
            exit(1);
        }
        close(cp[0]);
    } else {
        fprintf(2, "fork failed!\n");
    }

    exit(0);
}

