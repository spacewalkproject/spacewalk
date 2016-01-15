PY_VERSION	= $(shell python -c "import sys; print sys.version.split()[0]")
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
