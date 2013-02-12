TOP	= ..
SUBDIR	= locale
localedir = /usr/share/locale

NLSPACKAGE	= spacewalk-abrt
POTFILE		= $(NLSPACKAGE).pot

INSTALL         = /usr/bin/install -c --verbose
INSTALL_BIN     = $(INSTALL) -m 755
INSTALL_DATA    = $(INSTALL) -m 664
INSTALL_DIR     = $(INSTALL) -m 755 -d

MSGMERGE	= msgmerge -v
XGETTEXT	= xgettext --default-domain=$(NLSPACKAGE) --from-code utf-8 \
		  --add-comments
MSGFMT		= msgfmt --statistics --verbose

POFILES		= $(wildcard *.po)
MOFILES		= $(patsubst %.po,%.mo,$(POFILES))
SRCFILES = \
        $(wildcard ../src/spacewalk_abrt/*.py) \
        $(wildcard ../src/bin/*) \
        $(wildcard ../src/actions/*.py)

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
	@for n in $(wildcard *.mo); do \
	    l=`basename $$n .mo`; \
	    d="$(PREFIX)$(localedir)/$$l/LC_MESSAGES" ; \
	    $(INSTALL_DIR) $$d ; \
	    $(INSTALL_DATA) $$n $$d/$(NLSPACKAGE).mo ; \
	done

%.mo: %.po
	$(MSGFMT) -o $@ $<
