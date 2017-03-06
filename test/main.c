#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

int bss_glob;

int kk() {
    return 42;
}

int main(int argc, char **argv) {
    bss_glob = 42;

    void *handle;
    int (*testFn)(int);
    char *error;

    printf("dlopen...\n");
    handle = dlopen("./libr.so", RTLD_NOW);
    if (!handle) {
        fprintf(stderr, "%s\n", dlerror());
        exit(EXIT_FAILURE);
    }

    dlerror();
    printf("dlsym...\n");
    *(void **) (&testFn) = dlsym(handle, "testFn");

    if ((error = dlerror()) != NULL)  {
        fprintf(stderr, "%s\n", error);
        exit(EXIT_FAILURE);
    }

    printf("call...\n");
    printf("%i\n", (*testFn)(1));
    dlclose(handle);
    exit(EXIT_SUCCESS);
}
