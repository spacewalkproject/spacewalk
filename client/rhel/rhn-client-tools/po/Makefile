# Makefile for program source directory in GNU NLS utilities package.
# Copyright (C) 1995-1997, 2000, 2001 by Ulrich Drepper <drepper@gnu.ai.mit.edu>
#
# This file file be copied and used freely without restrictions.  It can
# be used in projects which are not available under the GNU Public License
# but which still want to provide support for the GNU gettext functionality.
# Please note that the actual code is *not* freely available.
#
#  Modified by Yukihiro Nakai <ynakai@redhat.com> to use pygettext.py
#  Modified by Yukihiro Nakai <ynakai@redhat.com> to use libglade-xgettext
#

PACKAGE = $(shell awk '/Name:/ { print $$2 }' ../rhn-client-tools.spec)
VERSION = $(shell awk '/Version:/ { print $$2 }' ../rhn-client-tools.spec)

# These two variables depend on the location of this directory.
subdir = po
top_builddir = ..

SHELL = /bin/sh


srcdir = .
top_srcdir = ..

PREFIX ?=
prefix = /usr
exec_prefix = $(PREFIX)${prefix}
datadir = $(PREFIX)${prefix}/share
localedir = $(datadir)/locale
gettextsrcdir = $(datadir)/gettext/po

INSTALL = /usr/bin/install -c
INSTALL_DATA = ${INSTALL} -m 644

GMSGFMT = /usr/bin/msgfmt
MSGFMT = /usr/bin/msgfmt
MSGMERGE = /usr/bin/intltool-update -x --gettext-package=$(PACKAGE) --dist

INCLUDES = -I.. -I$(top_srcdir)/intl

POFILES = $(shell ls *.po)
GMOFILES = $(patsubst %.po,%.gmo,$(POFILES))
DISTFILES = POTFILES.in $(PACKAGE).pot $(POFILES) $(GMOFILES)

POTFILES = \
	$(wildcard ../src/up2date_client/*.py) \
	$(wildcard ../src/firstboot/*.py) \
	$(wildcard ../src/bin/*.py) \
	$(wildcard ../src/actions/*.py) \
	$(wildcard ../data/*.glade) \
	../rhn_register.desktop.in

CATALOGS = $(GMOFILES)

.SUFFIXES:
.SUFFIXES: .po .pox .gmo .mo

.po.pox:
	$(MAKE) $(PACKAGE).pot
	$(MSGMERGE) $< $(srcdir)/$(PACKAGE).pot -o $*.pox

.po.mo:
	$(MSGFMT) -o $@ $<

.po.gmo:
	file=$(srcdir)/`echo $* | sed 's,.*/,,'`.gmo \
	  && rm -f $$file && $(GMSGFMT) --statistics -o $$file $<


all: all-yes desktop

all-yes: $(CATALOGS)
all-no:

desktop:
	intltool-merge -d . ../rhn_register.desktop.in ../rhn_register.desktop

# Note: Target 'all' must not depend on target '$(srcdir)/$(PACKAGE).pot',
# otherwise packages like GCC can not be built if only parts of the source
# have been downloaded.

POTFILES.in:
	echo "[encoding: UTF-8]" > $@
	for file in $(POTFILES); do \
	  echo "$${file#../}" ; \
	done >> $@

$(srcdir)/$(PACKAGE).pot: $(POTFILES) POTFILES.in
	/usr/bin/intltool-update --gettext-package=$(PACKAGE) --pot

install: install-exec install-data
install-exec:
install-data: install-data-yes
install-data-no: all
install-data-yes: all
	mkdir -p $(DESTDIR)$(datadir)
	@catalogs='$(CATALOGS)'; \
	for cat in $$catalogs; do \
	  cat=`basename $$cat`; \
	  lang=`echo $$cat | sed 's/\.gmo$$//'`; \
	  dir=$(localedir)/$$lang/LC_MESSAGES; \
	  mkdir -p $(DESTDIR)$$dir; \
	  if test -r $$cat; then \
	    $(INSTALL_DATA) $$cat $(DESTDIR)$$dir/$(PACKAGE).mo; \
	    echo "installing $$cat as $(DESTDIR)$$dir/$(PACKAGE).mo"; \
	  else \
	    $(INSTALL_DATA) $(srcdir)/$$cat $(DESTDIR)$$dir/$(PACKAGE).mo; \
	    echo "installing $(srcdir)/$$cat as" \
		 "$(DESTDIR)$$dir/$(PACKAGE).mo"; \
	  fi; \
	done

# Define this as empty until I found a useful application.
installcheck:

uninstall:
	catalogs='$(CATALOGS)'; \
	for cat in $$catalogs; do \
	  cat=`basename $$cat`; \
	  lang=`echo $$cat | sed 's/\.gmo$$//'`; \
	  rm -f $(DESTDIR)$(localedir)/$$lang/LC_MESSAGES/$(PACKAGE).mo; \
	done

check: all

dvi info tags TAGS ID:

mostlyclean:
	rm -f core core.* *.pox $(PACKAGE).po *.new.po POTFILES.in
	rm -fr *.o

clean: mostlyclean
	rm -f *.gmo

distclean: clean
	rm -f POTFILES *.mo

maintainer-clean: distclean
	@echo "This command is intended for maintainers to use;"
	@echo "it deletes files that may require special tools to rebuild."
	rm -f $(GMOFILES)

distdir = $(top_builddir)/$(PACKAGE)-$(VERSION)/$(subdir)
dist distdir:
	$(MAKE) update-po
	@$(MAKE) dist2
# This is a separate target because 'update-po' must be executed before.
dist2: $(DISTFILES)
	dists="$(DISTFILES)"; \
	for file in $$dists; do \
	  if test -f $$file; then dir=.; else dir=$(srcdir); fi; \
	  cp -p $$dir/$$file $(distdir); \
	done

update-po: Makefile POTFILES.in $(PACKAGE).pot
	$(MAKE) $(PACKAGE).pot
	if test "$(PACKAGE)" = "gettext"; then PATH=`pwd`/../src:$$PATH; fi; \
	cd $(srcdir); \
	catalogs='$(GMOFILES)'; \
	for cat in $$catalogs; do \
	  cat=`basename $$cat`; \
	  lang=`echo $$cat | sed 's/\.gmo$$//'`; \
	  echo "$$lang:"; \
	  cp $$lang.po $$lang.old.po; \
	  if $(MSGMERGE) $$lang; then \
	    rm -f $$lang.old.po ; \
	  else \
	    echo "msgmerge for $$cat failed!"; \
	    mv $$lang.old.po $$lang.po ; \
	  fi; \
	done
	$(MAKE) update-gmo

update-gmo: Makefile $(GMOFILES)
	@:

Makefile:

# Tell versions [3.59,3.63) of GNU make not to export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:
