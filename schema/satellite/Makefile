NAME := rhn-satellite-schema
SPECFILE := $(NAME).spec

#DO_TAR_GZ = svn-revision

include ../../../spec-tree/common/Makefile.svn

$(SPECFILE): universe.satellite.sql
	@echo '**Updating $<'
#	make -f ../build/Makefile SCHEMA=satellite schema-release
	make -f ../build/Makefile.schema TOP=.. UNIVERSE=$< all

.PHONY: $(SPECFILE)

