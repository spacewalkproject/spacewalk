# Makefile for the views SQL directory
#
# $Id$

all::

MAKEFILE= ../build/Makefile
TARGETS	= satellite production
RELEASE_TARGETS = $(foreach x,$(TARGETS),${x}-release)
DEVEL_TARGETS = $(foreach x,$(TARGETS),${x}-devel)
CLEAN_TARGETS = $(foreach x,$(TARGETS),${x}-clean)

clean :: 
	@find . -name \*~ -exec rm -fv {} \;
	@find . -name .\\#* -exec rm -fv {} \;
	@find . -name \*.pgsql -exec rm -fv {} \;
	@find . -name sqlnet.log -exec rm -fv {} \;
	@find . -name afiedt.buf -exec rm -fv {} \;

$(RELEASE_TARGETS) :: %-release : %
	$(MAKE) -C $< -f $(MAKEFILE) SCHEMA=$< release

# foo and foo-devel are the same thing
$(DEVEL_TARGETS) :: %-devel : %
	$(MAKE) -C $< -f $(MAKEFILE) SCHEMA=$< devel

$(CLEAN_TARGETS) :: %-clean : %
	$(MAKE) -C $< -f $(MAKEFILE) SCHEMA=$< clean

# don't pay attention to file stamps for these ones - always
# regenerate fully
.PHONY: $(TARGETS) $(RELEASE_TARGETS) $(DEVEL_TARGETS) $(CLEAN_TARGETS)

rpm: satellite-release
