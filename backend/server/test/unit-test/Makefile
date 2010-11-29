
TESTS       = \
        test_capabilities.py \
        test_misc_functions.py \
        test_rhnActivationKey.py \
        test_rhnChannel.py \
        test_rhnServerGroup.py \
        test_server_registration.py

all:	$(addprefix test-,$(TESTS))

test-%:
	@echo Running $*
	PYTHONPATH=$(PYTHONPATH):../../../ python $*
