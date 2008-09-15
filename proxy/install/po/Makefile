# Makefile for the PO files (translation) catalog
#
# $Id: Makefile,v 1.2 2002/06/17 14:49:09 misa Exp $

TOP	 = ../..

# Installation stuff
INSTALL		= /usr/bin/install -c --verbose
INSTALL_BIN	= $(INSTALL) -m 755
INSTALL_DATA	= $(INSTALL) -m 644
INSTALL_DIR	= $(INSTALL) -m 755 -d

# What is this package?
NLSPACKAGE	= proxy-install 
POTFILE		= $(NLSPACKAGE).pot

# destination directory
INSTALL_NLS_DIR = $(PREFIX)/usr/share/locale

# PO catalog handling
MSGMERGE	= msgmerge -v
PYGETTEXT	= ./pygettext.py --default-domain=$(NLSPACKAGE) \
		  --verbose --output-file=$(NLSPACKAGE).po 
XGETTEXT	= xgettext --default-domain=$(NLSPACKAGE) \
		  --add-comments		  
MSGFMT		= msgfmt --statistics --verbose

# What do we need to do
POFILES		= $(wildcard *.po)
MOFILES		= $(patsubst %.po,%.mo,$(POFILES))
PYSRC		= $(wildcard ../*.py)
SRCFILES	= $(PYSRC) gui.gladestrings progress.gladestrings

all:: $(MOFILES)

$(POTFILE): $(SRCFILES)
	@$(PYGETTEXT) --keyword=_ --keyword=N_ $(PYSRC)
	@if cmp -s $(NLSPACKAGE).po $(POTFILE); then \
	    rm -f $(NLSPACKAGE).po; \
	else \
	    mv -f $(NLSPACKAGE).po $(POTFILE); \
	fi; \
	$(XGETTEXT) --keyword=N_ configdlg.gladestrings; \
	msghack --append $(NLSPACKAGE).po $(POTFILE) -o $(POTFILE)-; \
	mv -f $(POTFILE)- $(POTFILE); \
	rm -f $(NLSPACKAGE).po
	$(XGETTEXT) --keyword=N_ gui.gladestrings; \
	msghack --append $(NLSPACKAGE).po $(POTFILE) -o $(POTFILE)-; \
	mv -f $(POTFILE)- $(POTFILE); \
	rm -f $(NLSPACKAGE).po
	$(XGETTEXT) --keyword=N_ progress.gladestrings; \
	msghack --append $(NLSPACKAGE).po $(POTFILE) -o $(POTFILE)-; \
	mv -f $(POTFILE)- $(POTFILE); \
	rm -f $(NLSPACKAGE).po

update-po: Makefile $(POTFILE) refresh-po

refresh-po: Makefile
	$(foreach cat,$(POFILES),\
                lang=`basename $(cat) .po`; \
		if $(MSGMERGE) $$lang.po $(POTFILE) > $$lang.pot ; then \
			mv -f $$lang.pot $$lang.po ; \
			echo "$(MSGMERGE) of $$lang succeeded" ; \
		else \
			echo "$(MSGMERGE) of $$lang failed" ; \
			rm -f $$lang.pot ; \
		fi; \
	)

clean:
	@rm -fv *mo *~ .depend

install: $(MOFILES)
	$(foreach n,$(MOFILES),\
	    l=`basename $n .mo`; \
	    $(INSTALL_DIR) $(INSTALL_NLS_DIR)/$$l/LC_MESSAGES; \
	    $(INSTALL_DATA) $n $(INSTALL_NLS_DIR)/$$l/LC_MESSAGES/$(NLSPACKAGE).mo; \
	)

%.mo: %.po
	@echo -n "$@: "
	@$(MSGFMT) -o $@ $<

.PHONY: missing depend

