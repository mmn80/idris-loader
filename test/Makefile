all:
	cc -c libr.c -fPIC -o libr.o
	cc libr.o -shared -fPIC -o libr.so
	cc main.c -ldl -rdynamic -o test
