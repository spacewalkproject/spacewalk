#
# Simple wrapper for setup.py script
#

DESTDIR=/
PYTHON=python

prefix=/usr
bindir=$(prefix)/bin

all:
	$(PYTHON) setup.py build

install:
	$(PYTHON) setup.py install \
		--root=$(DESTDIR) \
		--prefix=$(prefix) \
		--install-scripts=$(bindir)

dist:
	$(PYTHON) setup.py sdist

rpm:
	$(PYTHON) setup.py bdist_rpm

smart.pot:
	xgettext -o locale/smart.pot `find -name '*.c' -o -name '*.py'`

update-po: smart.pot
	for po in locale/*/LC_MESSAGES/smart.po; do \
		msgmerge -U $$po locale/smart.pot; \
	done

.PHONY: smart.pot update-po

