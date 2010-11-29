
DB_TESTS       = \
        test_capabilities.py \
        test_misc_functions.py \
        test_rhnActivationKey.py \
        test_rhnChannel.py \
	test_rhnDatabaseCache.py \
        test_rhnServerGroup.py \
        test_server_registration.py

TESTS       = \
        test_rhnLib_timestamp.py

all:	$(addprefix test-,$(TESTS))

test-%:
	@echo Running $*
	PYTHONPATH=$(PYTHONPATH):../../../ python $*
