FILES		:= abrt
PYFILES 	:= $(addsuffix .py, $(FILES))
PYCFILES	:= $(addsuffix .pyc, $(FILES))
INITFILE	:= __init__.py
OBJECTS		:= $(PYFILES) $(PYCFILES)

RHNSHARE_DIR	:= $(PREFIX)/usr/share/rhn

INSTALL         := install -p --verbose
INSTALL_DIR     := $(INSTALL) -m 755 -d
INSTALL_DATA    = $(INSTALL) -m 644

%.pyc: %.py
	python -c "import py_compile; py_compile.compile('$<')"

all:: $(OBJECTS)

install:: all
	$(INSTALL_DIR) $(RHNSHARE_DIR)/spacewalk_abrt
	$(INSTALL_DATA) $(PYFILES) $(INITFILE) $(RHNSHARE_DIR)/spacewalk_abrt

clean::
	@rm -fv *.pyc *~ .*~
