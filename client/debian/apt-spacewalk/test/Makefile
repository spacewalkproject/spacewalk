
.PHONY: run build

SCRIPTS=runtest.sh library.sh settings.sh sw_deb.py
FILES=$(SCRIPTS) equivs-template

run: $(FILES) build
	./runtest.sh

build:
	chmod a+x $(SCRIPTS)
