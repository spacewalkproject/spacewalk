TESTS       = \
        test_gettext.py \
        test_rhnCache.py \
        test_rhnLib.py

all:	$(addprefix test-,$(TESTS))

test-%:
	@echo Running $*
	@PYTHONPATH=$(PYTHONPATH):../../.. python $*
