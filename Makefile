IDRIS = idris
CC    = cc

EXE   = idris-loader
EXPO  = exports.o
EXPH  = exports.h

MODS  = Loader/Object/$(EXPO) Loader/Host/$(EXPO)
OBJS  = $(MODS:Loader/%=src/Loader/%)
DIRS  = $(OBJS:%/$(EXPO)=%)

$(MODS):
	cd src; $(IDRIS) $(@:$(EXPO)=Main.idr) --interface -o $@

build: $(MODS)
	$(CC) src/Loader/Host/main.c $(OBJS) `$(IDRIS) --include` `$(IDRIS) --link` -o $(EXE)

clean:
	for dir in $(DIRS) ; do \
	    rm -f $$dir/$(EXPO) $$dir/$(EXPH) $$dir/*.ibc ; \
	done
	rm -f src/Loader/Shared/*.ibc
	rm -f $(EXE)
