# Makefile for schema verification tools
#
# $Id: Makefile,v 1.8 2004-06-25 21:50:05 misa Exp $

# defines that can be changed
ROOT		= /usr/share/rhn

INSTALL_DEST	= $(PREFIX)$(ROOT)/schema

SCRIPTS		= verify dump listobjs
FILES		= __init__ DBObjects $(SCRIPTS)

PYFILES		= $(addsuffix .py, $(FILES))
PYCFILES	= $(addsuffix .pyc, $(FILES))

all: $(PYFILES) $(PYCFILES)

install : $(INSTALL_DEST) $(PYFILES) $(PYCFILES)
	@install -m 644 $(PYFILES) $(PYCFILES) $(INSTALL_DEST)
	@$(foreach f,$(SCRIPTS), chmod +x $(INSTALL_DEST)/$(f).py ; )

$(INSTALL_DEST) :
	install -d -m 755 $@

# default compile rule:
%.pyc: %.py
	python -c "import py_compile; py_compile.compile('$<')"

# Common rules
clean::
	@rm -fv *~ *.pyc

