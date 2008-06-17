# This file builds universe.*.sql, tests it, tags it, and rpms it.
# oh, and it filets it.

# $Id$

TOP	?= ..
SCHEMA	?= no-schema
VERSION	= $(shell /bin/awk '{ print $$2 }' schema-info 2>/dev/null)
RELEASE	= $(shell /bin/awk '{ print $$3 }' schema-info 2>/dev/null)
UNIVERSE= universe.$(SCHEMA).sql
export VERSION RELEASE TOP SCHEMA UNIVERSE

# there has got to be a cleaner way to do this
TARGETS = schema test tag rpm
CLEAN_TARGETS = $(foreach x,$(filter-out tag,$(TARGETS)),${x}-clean)
DEVEL_TARGETS = $(foreach x,$(filter-out tag,$(TARGETS)),${x}-devel)
RELEASE_TARGETS = $(foreach x,$(TARGETS),${x}-release)

all : $(SCHEMA)

# $(SCHEMA) here gets us no-schema if it's unset; it keeps us out of trouble
devel :: $(SCHEMA) $(DEVEL_TARGETS)
%-devel :
	$(MAKE) -f $(TOP)/build/Makefile.$* all

clean :: $(SCHEMA) $(CLEAN_TARGETS)
%-clean : 
	$(MAKE) -f $(TOP)/build/Makefile.$* clean

# this is just like devel, except with tag as well.
release :: $(SCHEMA) $(RELEASE_TARGETS)
%-release :
	$(MAKE) -f $(TOP)/build/Makefile.$* all

no-schema :
	@echo "Apparently you don't know what you're doing..."
	@exit -1

# .PHONY :: $(RELEASE_TARGETS) $(DEVEL_TARGETS) $(CLEAN_TARGETS)
.PHONY :: all clean release devel $(SCHEMA)
