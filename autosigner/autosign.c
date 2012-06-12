#include <stdio.h>
#include <unistd.h>

char *getpass(const char *prompt)
{
    printf("INFO: Overriding passphrase prompt.\n");
    fflush(stdout);
    return "";
}

