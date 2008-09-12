NAME := rhn-satellite-schema
SPECFILE := $(NAME).spec

#DO_TAR_GZ = svn-revision

include ../../../spec-tree/common/Makefile.svn

UNIVERSE := universe.satellite.sql

$(SPECFILE):
	@echo '**Updating $(UNIVERSE)'
	make -f ../build/Makefile SCHEMA=satellite schema-clean schema-release
#	make -f ../build/Makefile.schema TOP=.. UNIVERSE=$(UNIVERSE) all

.PHONY: $(SPECFILE)

