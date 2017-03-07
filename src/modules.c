#include "modules.h"
#include <stdio.h>

char* _testFn1(void* fn, void* vm, int arg) {
  printf("fn: 0x%8x\n", fn);
  printf("vm: 0x%8x\n", vm);
  char* (*fnPtr)(void*, int);
  *(void **) (&fnPtr) = fn;
  return (*fnPtr)(vm, arg);
}
