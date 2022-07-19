#include "../kernel/types.h"
#include "../user/user.h"
#include "../kernel/param.h"

const char *line_option = "-n";

void run_cmd_per_line(char *cmd, char *exec_args[]) {
    int ret;
    if ((ret = fork()) == 0) {
        if (exec(cmd, exec_args) == -1) {
            fprintf(1, "xargs: there is no command like %s!\n", cmd);
            exit(1);
        }
    } else if (ret > 0) {
        wait(0);
    } else {
        fprintf(2, "fork failed!\n");
        exit(1);
    }
}

void xargs(char *cmd, int line, char *exec_args[], int arg_idx) {

    char c;
    if (0 == read(0, &c, 1)) {
        run_cmd_per_line(cmd, exec_args);
        return;
    }
    int ret = 1;
    int cnt = 0;
    int j = arg_idx;
    do {
        if (c == '"' || c == '\n') {
            continue;
        }
        if (cnt == 0) {
            j = arg_idx;
        }
        char *buf = malloc(512);
        int i = 0;
        buf[i++] = c;
        char pre_c = c;

        while ((ret = read(0, &c, 1)) == 1 && c != '\n') {
            if (c == '"') {
                continue;
            }
            if (pre_c == '\\' && c == 'n') {
                buf[i - 1] = 0;
                break;
            }
            pre_c = c;
            buf[i++] = c;
        }
        if (ret == 0 || c == '\n') {
            buf[i] = 0;
        }
        exec_args[j++] = buf;
        ++cnt;
        if (ret == 0 || cnt >= line) {
            exec_args[j] = 0;
            run_cmd_per_line(cmd, exec_args);
            for (int k = arg_idx; k < j; ++k) {
                free(exec_args[k]);
            }
            cnt = 0;
        }
    } while (ret != 0 && 0 != (read(0, &c, 1)));

    if (cnt > 0) {
        exec_args[j] = 0;
        run_cmd_per_line(cmd, exec_args);
        for (int k = arg_idx; k < j; ++k) {
            free(exec_args[k]);
        }
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(2, "Usage: xargs [-n lines] command [args]\n");
        exit(1);
    }
    int cmd_idx = 1;
    int arg_beg = 2;
    int line = 1;
    if (strcmp(argv[1], line_option) == 0) {
        if (argc < 4) {
            fprintf(2, "Usage: xargs [-n lines] command [args]\n");
            exit(1);
        }
        line = atoi(argv[2]);
        if (line < 0) {
            line = 1;
        }
        cmd_idx = 3;
        arg_beg = 4;
    }

    char *cmd = argv[cmd_idx];
    char *exec_args[MAXARG];
    int arg_idx = 0;
    exec_args[arg_idx++] = cmd;
    for (; arg_beg < argc; ++arg_beg) {
        exec_args[arg_idx++] = argv[arg_beg];
    }
    exec_args[arg_idx] = 0;
    xargs(cmd, line, exec_args, arg_idx);

    exit(0);
}
