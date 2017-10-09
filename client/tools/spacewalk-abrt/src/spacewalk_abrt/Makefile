FILES		:= abrt
PYFILES 	:= $(addsuffix .py, $(FILES))
INITFILE	:= __init__.py
OBJECTS		:= $(PYFILES)

PYTHON_DIR	:= $(PREFIX)$(PYTHON_PATH)

INSTALL         := install -p --verbose
INSTALL_DIR     := $(INSTALL) -m 755 -d
INSTALL_DATA    = $(INSTALL) -m 644

all:: $(OBJECTS)

install:: all
	$(INSTALL_DIR) $(PYTHON_DIR)/spacewalk_abrt
	$(INSTALL_DATA) $(PYFILES) $(INITFILE) $(PYTHON_DIR)/spacewalk_abrt

clean::
	@rm -fv *.pyc *~ .*~
