all:
	cc -c libr.c -fPIC -o libr.o
	cc libr.o -shared -fPIC -o libr.so
	cc main.c -fwrapv -fno-strict-overflow -O2 -DHAS_PTHREAD -DIDRIS_ENABLE_STATS -ldl `idris --link` `idris --include` -rdynamic -o test

clean:
	rm -f test *.o *.so

.PHONY: build clean
