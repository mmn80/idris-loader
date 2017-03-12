#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <idris_rts.h>

int bss_glob;

int kk() {
    return 42;
}

void testIdris();

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

    testIdris();

    exit(EXIT_SUCCESS);
}

void testIdris() {
    void *handle;
    char* (*testFn1)(VM* vm, int arg0);
    char *error;

    printf("Initializing Idris vm...\n");
    VM* vm = idris_vm();

    printf("dlopen Idris module...\n");
    handle = dlopen("../src/Module1/exports.so", RTLD_LAZY);
    if (!handle) {
        fprintf(stderr, "%s\n", dlerror());
        exit(EXIT_FAILURE);
    }

    dlerror();
    printf("dlsym...\n");
    *(void **) (&testFn1) = dlsym(handle, "testFn1");

    if ((error = dlerror()) != NULL)  {
        fprintf(stderr, "%s\n", error);
        exit(EXIT_FAILURE);
    }

    printf("call...\n");
    printf("%s\n", (*testFn1)(vm, 42));

    printf("closing Idris vm...\n");
    //idris_gcInfo(vm, 1);
    Stats stats = terminate(vm);
    print_stats(&stats);
    //close_vm(vm);

    dlclose(handle);
}
