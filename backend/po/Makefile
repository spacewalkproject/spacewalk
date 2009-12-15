# Makefile for the PO files (translation) catalog
#
# $Id$

TOP	= ..
SUBDIR	= locale

include $(TOP)/Makefile.defs

# What is this package?
NLSPACKAGE	= server
POTFILE		= $(NLSPACKAGE).pot

# PO catalog handling
MSGMERGE	= msgmerge -v
PYGETTEXT	= ./pygettext.py --default-domain=$(NLSPACKAGE) \
		  --verbose --output-file=$(NLSPACKAGE).po 
XGETTEXT	= xgettext --default-domain=$(NLSPACKAGE) --from-code utf-8 \
		  --add-comments		  
MSGFMT		= msgfmt --statistics --verbose

# What do we need to do
POFILES		= $(wildcard *.po)
MOFILES		= $(patsubst %.po,%.mo,$(POFILES))
SRCFILES	= $(shell find ../server -name \*.py) \
		  $(shell find ../common -name \*.py)

all:: $(MOFILES)

$(POTFILE): $(SRCFILES)
	@$(XGETTEXT) --keyword=_ --keyword=N_ $(SRCFILES)
	@if cmp -s $(NLSPACKAGE).po $(POTFILE); then \
	    rm -f $(NLSPACKAGE).po; \
	else \
	    mv -f $(NLSPACKAGE).po $(POTFILE); \
	fi

update-po: Makefile $(POTFILE) refresh-po

refresh-po: Makefile
	for cat in $(POFILES); do \
		lang=`basename $$cat .po`; \
		if $(MSGMERGE) $$lang.po $(POTFILE) > $$lang.pot ; then \
			mv -f $$lang.pot $$lang.po ; \
			echo "$(MSGMERGE) of $$lang succeeded" ; \
		else \
			echo "$(MSGMERGE) of $$lang failed" ; \
			rm -f $$lang.pot ; \
		fi \
	done

clean ::
	@rm -fv *mo *~ .depend

install :: $(MOFILES)
	@for n in $(MOFILES); do \
	    l=`basename $$n .mo`; \
	    d="$(PREFIX)$(INSTALL_DEST)/$$l/LC_MESSAGES" ; \
	    $(INSTALL_DIR) $$d ; \
	    $(INSTALL_DATA) $$n $$d/$(NLSPACKAGE).mo ; \
	done

%.mo: %.po
	$(MSGFMT) -o $@ $<
