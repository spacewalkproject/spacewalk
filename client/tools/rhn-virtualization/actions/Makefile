PYTHON=python
PYFILES = $(wildcard *.py)
PKGDIR = $(PYTHONPATH)/rhn/actions/

all: 
	echo "Nothing to do"

clean:
	rm -f *.pyc *.pyo *~

install:
	mkdir -p $(DESTDIR)/$(PKGDIR)
	for p in $(PYFILES) ; do \
		install -m 644 $$p $(DESTDIR)/$(PKGDIR)/$$p; \
	done
