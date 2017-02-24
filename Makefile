IDRIS := idris
CC    := cc
PKG   := idris-loader.ipkg
EXE   := idris-loader
EXP_O := src/entryPoint.o
EXP_H := src/entryPoint.h

build:
	$(IDRIS) --build $(PKG)
	$(CC) main.c $(EXP_O) `$(IDRIS) --include` `$(IDRIS) --link` -o $(EXE)

clean:
	$(IDRIS) --clean $(PKG)
	rm -f $(EXE) $(EXP_O) $(EXP_H)
