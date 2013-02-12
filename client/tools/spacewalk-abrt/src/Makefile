PREFIX ?=
VERSION ?=

SUBDIRS         = bin spacewalk_abrt

export PREFIX
export VERSION
export PLATFORM

all::

install:: all

clean::
	@rm -fv *~ .*~
	@find . -name .\#\* -exec rm -fv {} \;

descend-subdirs = @$(foreach d,$(SUBDIRS), $(MAKE) -C $(d) $@ || exit 1; )

all clean install :: $(SUBDIRS)
	$(descend-subdirs)
