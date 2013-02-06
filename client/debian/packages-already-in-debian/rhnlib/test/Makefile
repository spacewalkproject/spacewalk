# $Id$
PY_VERSION	= $(shell python -c "import sys, string; print string.split(sys.version)[0]")
FILES		= $(wildcard *.py)

.PHONY: all test compile 

all:

test: compile $(FILES)

compile:
	@python /usr/lib/python$(PY_VERSION)/compileall.py .

%.py: %.pyc
	@python $< || exit 1

clean:
	@rm -fv `cat .cvsignore`
