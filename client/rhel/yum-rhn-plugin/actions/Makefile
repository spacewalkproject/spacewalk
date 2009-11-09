PREFIX ?= /

PYTHON ?= python
PYFILES = $(wildcard *.py)
PKGDIR = usr/share/rhn/actions/

all: 
	echo "Nothing to do"

clean:
	rm -f *.pyc *.pyo *~

install:
	mkdir -p $(PREFIX)/$(PKGDIR)
	for p in $(PYFILES) ; do \
		install -m 644 $$p $(PREFIX)/$(PKGDIR)/$$p; \
	done
	$(PYTHON) -c "import compileall; compileall.compile_dir('$(PREFIX)/$(PKGDIR)', 1, '$(PYDIR)', 1)"
