#include "src/entryPoint.h"

int main() {
    VM* vm = idris_vm();
    myMain(vm);
    close_vm(vm);
}
