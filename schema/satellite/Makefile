NAME := rhn-satellite-schema
SPECFILE := $(NAME).spec

#DO_TAR_GZ = svn-revision

include ../../../spec-tree/common/Makefile.svn

UNIVERSE := universe.satellite.sql
SCHEMA   := satellite
VERSION  := $(shell awk '{print $$1}' $(VERSION_FILE))
RELEASE  := $(shell awk '{print $$2}' $(VERSION_FILE))

$(SPECFILE):
	@echo '**Updating $(UNIVERSE)'
	make -f ../build/Makefile \
	  SCHEMA=$(SCHEMA) VERSION=$(VERSION) RELEASE=$(RELEASE) \
	  schema-clean schema-release
#	make -f ../build/Makefile.schema TOP=.. UNIVERSE=$(UNIVERSE) all

.PHONY: $(SPECFILE)

