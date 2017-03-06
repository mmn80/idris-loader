extern int bss_glob;
extern int kk();

int testFn(int arg) {
  return arg + kk() + bss_glob;
}
