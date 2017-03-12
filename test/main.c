#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <idris_rts.h>
#include "idris_stdfgn.h"

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
    char *error;

    printf("Initializing Idris vm...\n");
    VM* vm = idris_vm();

    idris_forceGC(vm);

    void *h1;
    char* (*testFn1)(VM* vm, int arg0);

    printf("dlopen Module1...\n");
    h1 = dlopen("../src/Module1/exports.so", RTLD_NOW);
    if (!h1) {
      fprintf(stderr, "%s\n", dlerror());
      exit(EXIT_FAILURE);
    }

    dlerror();
    printf("dlsym testFn1...\n");
    *(void **) (&testFn1) = dlsym(h1, "testFn1");

    if ((error = dlerror()) != NULL)  {
      fprintf(stderr, "%s\n", error);
      exit(EXIT_FAILURE);
    }

    printf("call testFn1...\n");
    printf("%s\n", (*testFn1)(vm, 42));

    //dlclose(h1);

    void *h2;
    char* (*testFn2)(VM* vm, int arg0);

    printf("dlopen Module2...\n");
    h2 = dlopen("../src/Module2/exports.so", RTLD_NOW);
    if (!h2) {
      fprintf(stderr, "%s\n", dlerror());
      exit(EXIT_FAILURE);
    }

    dlerror();
    printf("dlsym testFn2...\n");
    *(void **) (&testFn2) = dlsym(h2, "testFn2");

    if ((error = dlerror()) != NULL)  {
      fprintf(stderr, "%s\n", error);
      exit(EXIT_FAILURE);
    }

    printf("call testFn2...\n");
    printf("%s\n", (*testFn2)(vm, 442));

    dlclose(h2);
    dlclose(h1);

    printf("closing Idris vm...\n");
    //idris_gcInfo(vm, 1);
    Stats stats = terminate(vm);
    print_stats(&stats);
    //close_vm(vm);
}
