IDRIS = idris
CC    = cc

EXE   = idris-loader
EXPO  = exports.o
EXPH  = exports.h
EXPS  = libexports.so

MODS  = Loader/Object/$(EXPS) Loader/Host/$(EXPS)
OBJS  = $(MODS:Loader/%=src/Loader/%)
DIRS  = $(OBJS:%/$(EXPS)=%)

$(MODS):
	cd src; $(IDRIS) $(@:$(EXPS)=Main.idr) --interface --cg-opt="-fPIC" -o $(@:$(EXPS)=$(EXPO))
	cd src; $(CC) $(@:$(EXPS)=$(EXPO)) -shared -fPIC -o $@

build: $(MODS)
	$(CC) src/Loader/Host/main.c $(OBJS) `$(IDRIS) --include` `$(IDRIS) --link` -o $(EXE)

clean:
	for dir in $(DIRS) ; do \
	    rm -f $$dir/$(EXPO) $$dir/$(EXPH) $$dir/$(EXPS) $$dir/*.ibc ; \
	done
	rm -f src/Loader/Shared/*.ibc
	rm -f $(EXE)
