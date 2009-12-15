# Makefile for installing man pages for the up2date client
#
# $Id$

# INSTALL scripts 
INSTALL         = install --verbose 
INSTALL_BIN     = $(INSTALL) -m 755 
INSTALL_DIR     = $(INSTALL) -m 755 -d 
INSTALL_DATA    = $(INSTALL) -m 644 

all :

MANPATH	= /usr/share/man
MANDIR	= $(PREFIX)/$(MANPATH)
CAT	= 8
LANGDIR	= 

DIRS	= $(addprefix $(MANDIR)/man,$(CAT))

# dummy
newline	=
# handle install for a lang and catman
define install_lang_catman
@if [ -n "$(wildcard $(lang)/*.$(catman))" ] ; then \
    $(INSTALL_DIR) $(MANDIR)/$(lang)/man$(catman) ; \
    $(INSTALL_DATA) $(lang)/*.$(catman) $(MANDIR)/$(lang)/man$(catman) ; \
fi
$(newline)
endef

# handle install for a lang
define install_lang
$(foreach catman, $(CAT), $(install_lang_catman) )
$(newline)
endef

# default man pages
define install_default
$(foreach catman, $(CAT), 
    @if [ -n "$(wildcard en/*.$(catman))" ] ; then \
        $(INSTALL_DATA) en/*.$(catman) $(MANDIR)/man$(catman) ; \
    fi
    $(newline) )
endef

# Some of this is wicked make
install: $(DIRS)
	$(install_default)
	$(foreach lang, $(LANGDIR), $(install_lang) )

$(DIRS) :
	$(INSTALL_DIR) $@

clean :
	@find . -name \*~ -exec rm -fv {} \;
