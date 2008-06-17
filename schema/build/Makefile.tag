SCHEMA		?= no-schema

# List all the objects we are to tag
TAG_OBJECTS     = Makefile build rhn web $(SCHEMA)
SVN             = svn
SVN_DIR         = svn+ssh://svn.rhndev.redhat.com/svn/rhn-svn/trunk/eng/schema
SVN_TAG_DIR     = svn+ssh://svn.rhndev.redhat.com/svn/rhn-svn/tags/automatic-builds/rhn-satellite-schema
SVN_VERSION	= $(shell echo $(VERSION) | sed 's/\./_/g')
SVN_RELEASE	= $(shell echo $(RELEASE) | sed 's/\./_/g')
SVN_TAG		= rhn-$(SCHEMA)-schema-$(SVN_VERSION)-$(SVN_RELEASE)

all:
	@echo "Tagging $(SCHEMA) schema tree as $(SVN_TAG)"
	@$(SVN) cp -m "Automatic tagging of $(SVN_TAG)" $(SVN_DIR) $(SVN_TAG_DIR)/$(SVN_TAG)

no-schema :
	@echo "Apparently you don't know what you're doing..."
	@exit -1
