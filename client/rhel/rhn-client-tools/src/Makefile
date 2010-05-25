# Makefile for Update Agent
#
# $Id$

PREFIX ?=
VERSION ?=

# Dirs we need to walk into
SUBDIRS		= up2date_client actions firstboot firstboot-legacy-rhel5 bin

# For subdirs, required exports 
export PREFIX 
export VERSION

all::

install:: all

clean::
	@rm -fv *~ .*~
	@find . -name .\#\* -exec rm -fv {} \;

# useful macro
descend-subdirs = @$(foreach d,$(SUBDIRS), $(MAKE) -C $(d) $@ || exit 1; )

# Now do the same in the subdirs
all clean install :: $(SUBDIRS)
	$(descend-subdirs)
