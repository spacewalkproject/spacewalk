
THIS_MAKEFILE := $(realpath $(lastword $(MAKEFILE_LIST)))
README_FILE = $(wildcard $(dir $(THIS_MAKEFILE))README)

GIT_TO_DIST_CVS_RC := ~/.git-to-dist-cvs-rc

ifneq (,$(wildcard $(GIT_TO_DIST_CVS_RC)))
GIT_TO_DIST_CVS_RC_FILE := $(wildcard $(GIT_TO_DIST_CVS_RC))
include $(GIT_TO_DIST_CVS_RC_FILE)
endif

GIT_CHECKOUT_DIR := $(CURDIR)
override GIT_COMMIT_ID := $(shell git-rev-parse --verify HEAD)
# FIXME: SVN_CHECKOUT_REVISION
# FIXME: SVN_CHECKOUT_URL
# override SVN_CHECKOUT_URL := $(shell svn info 2> /dev/null | perl -lne 'if (/^URL:\s(.+)$$/) { print $$1 }')

DIST_CVS_BRANCHES_FILES := $(addsuffix dist-cvs-branches,./ $(dir $(THIS_MAKEFILE)))
override DIST_CVS_BRANCHES_FILE := $(firstword $(wildcard $(DIST_CVS_BRANCHES_FILES)))

ifdef DIST_CVS_BRANCHES_FILE
override DIST_CVS_BRANCHES := $(shell grep -v '^\#' $(DIST_CVS_BRANCHES_FILE) )
override DIST_CVS_BRANCHES_FULL := $(addprefix $(NAME)-,$(DIST_CVS_BRANCHES))
override DIST_CVS_BRANCHES_PURE := $(strip $(foreach branch,$(DIST_CVS_BRANCHES),$(if $(filter ./,$(dir $(branch))),$(branch),)))
override DIST_CVS_BRANCHES_ZSTREAM := $(strip $(foreach branch,$(DIST_CVS_BRANCHES),$(if $(filter ./,$(dir $(branch))),,$(branch))))
override DIST_CVS_BRANCHES_ZSTREAM_BASES := $(sort $(patsubst %/,%,$(dir $(DIST_CVS_BRANCHES_ZSTREAM))))
override DIST_CVS_BRANCHES_ZSTREAM_NAMES := $(notdir $(DIST_CVS_BRANCHES_ZSTREAM))
override VERSION_FILES := $(wildcard $(addprefix version.,$(DIST_CVS_BRANCHES_ZSTREAM_NAMES)))
override DIST_CVS_BRANCHES_BASES_FULL := $(addprefix $(NAME)-, $(sort $(DIST_CVS_BRANCHES_PURE) $(DIST_CVS_BRANCHES_ZSTREAM_BASES)))
override DIST_CVS_BRANCHES_ZSTREAM_BASES_FULL_PATH := $(addsuffix /$(NAME),$(addprefix $(DIST_CVS_WORKDIR)/$(NAME)-,$(DIST_CVS_BRANCHES_ZSTREAM_BASES)))
override DIST_CVS_BRANCHES_FULL_PATH := $(addprefix $(DIST_CVS_WORKDIR)/$(NAME)-, $(addsuffix /$(NAME),$(DIST_CVS_BRANCHES_PURE)) $(DIST_CVS_BRANCHES_ZSTREAM))
endif


VERSION_FILE := version

EXISTING_ARCHIVES := $(wildcard *.tar.gz *.zip *.jar)
EXISTING_SRC_RPM := $(wildcard *.src.rpm)

ifdef KEEP_VERSION
BUMP_VERSION := check-keep-version
else
BUMP_VERSION := bump-version
endif

CMP_OR_CP_SCRIPT := cmp-or-cp.sh
CMP_OR_CP := $(realpath $(dir $(THIS_MAKEFILE))$(CMP_OR_CP_SCRIPT))

UPLOAD_SCRIPT := upload-file.sh
UPLOAD := $(realpath $(dir $(THIS_MAKEFILE))$(UPLOAD_SCRIPT))

RPMBUILD := $(shell if test -f /usr/bin/rpmbuild ; then echo rpmbuild ; else echo rpm ; fi)
RPMBUILD_CURDIR = --define "_sourcedir $(CURDIR)" \
                --define "_builddir $(CURDIR)" \
                --define "_srcrpmdir $(CURDIR)" \
                --define "_rpmdir $(CURDIR)"

ifdef SCRATCH_BREW_ARCH
ifneq (all,$(SCRATCH_BREW_ARCH))
BREW_BUILD_ARCH := --arch-override=$(SCRATCH_BREW_ARCH)
endif
else
BREW_BUILD_ARCH := --arch-override=i386
endif

ifdef DO_TAR_GZ
ifeq (git-tree-sha1,$(DO_TAR_GZ))
override NAME_TAR_GZ_DIR = $(NAME)-git-$(GIT_COMMIT_ID)
else ifeq (version,$(DO_TAR_GZ))
override NAME_TAR_GZ_DIR = $(NAME)-$(shell awk '{print $$1}' $(VERSION_FILE))
else
$(error Unsupported DO_TAR_GZ parameter $(DO_TAR_GZ))
endif
override NAME_TAR_GZ = $(NAME_TAR_GZ_DIR).tar.gz
override RUN_TAR_GZ := tar-gz-to-sources
override TEST_RUN_TAR_GZ := md5sum-tar-gz-to-sources
override CLEAR_TAR_GZ := clear-tar-gz
endif

ifdef TAR_GZ_MAKEFILE_NAME
TAR_GZ_MAKEFILE_NAME_TEST := $(TAR_GZ_MAKEFILE_NAME)
else
TAR_GZ_MAKEFILE_NAME_TEST := Makefile
endif

REPOSITORY = http://repository.example.com/repo/dist

TODAY = $(shell LC_ALL=C date +"%a %b %_d %Y")

release : test-name test-svn $(SPECFILE) checkout-cvs \
	$(RUN_TAR_GZ) $(CLEAR_TAR_GZ) $(BUMP_VERSION) \
	update-changelog copy-svn-to-cvs make-build

test-srpm : $(TEST_RUN_TAR_GZ) download-sources
	$(RPMBUILD) $(RPMBUILD_CURDIR) --nodeps -bs $(SPECFILE)

download-sources :
	@if test -f sources ; then \
		while read md5 file ; do \
			if ! echo "$$md5  $$file" | md5sum --status -c - 2> /dev/null ; then \
				echo "Downloading [$$file] ..." ; \
				curl --fail -o $$file $(REPOSITORY)/$(NAME)/$$file/$$md5/$$file ; \
			fi ; \
		done < sources ; \
	fi

scratch-build : test-srpm
	@if test -z "$(SCRATCH_BREW_TAG)" ; then echo "Please specify the SCRATCH_BREW_TAG argument when running scratch-build" ; exit 1 ; fi
	brew build $(BREW_BUILD_ARCH) --nowait --scratch $(SCRATCH_BREW_TAG) *.src.rpm

test-release : test-name checkout-cvs copy-svn-to-cvs make-build

test-name :
	@if test -z "$(NAME)" ; then echo "In the Makefile in your package directory, please specify NAME."; exit 1 ; fi
	@echo "Package name: [$(NAME)]"

test-svn :
	@if test -z "$(SVN_CHECKOUT_REVISION)" ; then echo "The directory [$(SVN_CHECKOUT_DIR)] does not seem like SVN checkout."; exit 1 ; fi
	@echo "Local SVN checkout: [$(SVN_CHECKOUT_DIR)] revision: [$(SVN_CHECKOUT_REVISION)]"
	@if test -n "$(SVN_REVISION)" -a "$(SVN_REVISION)" != "$(SVN_CHECKOUT_REVISION)" ; then \
		echo "The checkout revision [$(SVN_CHECKOUT_REVISION)] does not match [$(SVN_REVISION)] requested by the SVN_REVISION parameter." ; \
		echo "You might want to run svn up -r $(SVN_REVISION)."; \
		exit 1 ; fi
	@if test -z "$(SVN_REVISION)" ; then \
		echo "Retrieving SVN HEAD revision ..." ; \
		SVN_HEAD_REVISION=`svn info -r HEAD | perl -lne 'if (/^Revision:\s(\d+)$$/) { print $$1 }'` ; \
		if test "x$$SVN_HEAD_REVISION" != "x$(SVN_CHECKOUT_REVISION)"; then \
			echo "HEAD revision is [$$SVN_HEAD_REVISION] while checkout revision is [$(SVN_CHECKOUT_REVISION)]." ; \
			echo "Use parameter SVN_REVISION, or do svn up." ; \
			exit 1 ; fi ; fi
	@echo Checking if SVN directory is fresh checkout ...
	@if test -n "`svn status | perl -pe 'print STDERR'`" ; then \
		echo "Your checkout has some local modifications, commit them or revert them." ; exit 1 ; fi

test-cvs :
	@if test -z "$(DIST_CVS_WORKDIR)" ; then echo "In your [$(GIT_TO_DIST_CVS_RC)], please specify DIST_CVS_WORKDIR." ; exit 1 ; fi
	@echo "Dist-cvs work dir (DIST_CVS_WORKDIR): [$(DIST_CVS_WORKDIR)]"

$(DIST_CVS_WORKDIR)/. :
	@echo "Please create your DIST_CVS_WORKDIR [$(DIST_CVS_WORKDIR)]"
	@echo "   as specified in your [$(GIT_TO_DIST_CVS_RC)]."
	@echo "We could run that mkdir -p for you but we are lazy, and besides,"
	@echo "we would not want to mess something on your machine."
	@exit 1

test-cvs-branches :
	@if test -z "$(DIST_CVS_BRANCHES_FILE)" ; then echo "No dist-cvs-branches file found (searched [$(DIST_CVS_BRANCHES_FILES)])." ; exit 1 ; fi
	@if test -z "$(DIST_CVS_BRANCHES)" ; then echo "No dist-cvs-branches specified in [$(DIST_CVS_BRANCHES_FILE)]." ; exit 1 ; fi
	@echo "Dist-cvs branches: [$(DIST_CVS_BRANCHES)] (from [$(DIST_CVS_BRANCHES_FILE)])"

$(CMP_OR_CP) :
	@echo "It looks like the [$(CMP_OR_CP_SCRIPT)] script does not exist."
	@exit 1

checkout-cvs : test-cvs $(DIST_CVS_WORKDIR)/. test-cvs-branches $(CMP_OR_CP)
	@echo "Checking out [$(DIST_CVS_BRANCHES_BASES_FULL)] into [$(DIST_CVS_WORKDIR)] ..."
	@cd $(DIST_CVS_WORKDIR) && cvs -d :gserver:repository.example.com:/cvs/dist -q checkout $(DIST_CVS_BRANCHES_BASES_FULL)
	for i in $(DIST_CVS_BRANCHES_ZSTREAM_BASES_FULL_PATH) ; do make -C $$i zstreams ; done

bump-version : test-version
	@for version_file in $(VERSION_FILE) $(VERSION_FILES) ; do \
		ORIG_VERSION=`cat $$version_file` ; \
		BUMPED_VERSION=`perl -pe 's!^(\S+\s(.+\.)*)(\d+)([\.%].+)?$$!$$1 . ($$3 + 1) . $$4!e' $$version_file` ; \
		if test -z "$$BUMPED_VERSION" ; then echo "Failed to bump the version [$$ORIG_VERSION] (got empty)." ; exit 1 ; fi ; \
		if test "x$$ORIG_VERSION" == "x$$BUMPED_VERSION" ; then echo "Failed to bump the version [$$ORIG_VERSION] (got the same)." ; exit 1 ; fi ; \
		echo "Bumping $$version_file from [$$ORIG_VERSION] to [$$BUMPED_VERSION]." ; \
		echo $$BUMPED_VERSION > $$version_file ; \
	done

check-keep-version : test-version
	@ORIG_VERSION=`cat $(VERSION_FILE)`; \
		if test "x$$ORIG_VERSION" != "x$(KEEP_VERSION)" ; then \
		echo "Version mismatch: current [$$ORIG_VERSION], KEEP_VERSION parameter [$(KEEP_VERSION)]." ; exit 1 ; fi
	@echo "Keeping version at [$(KEEP_VERSION)]."

test-version :
	@ORIG_VERSION=`cat $(VERSION_FILE) 2> /dev/null`; \
		if test -z "$$ORIG_VERSION" ; then \
		echo "Failed to retrieve the original version -- version file [$(VERSION_FILE)] does not exist?" ; exit 1 ; fi

make-upload :
	@if test -n "$(EXISTING_ARCHIVES)" ; then \
		$(UPLOAD) $(NAME) $(EXISTING_ARCHIVES) > .sources.new ; \
		if test -f sources ; then \
			if ! cmp sources .sources.new ; then \
				echo "Updating the sources list." ; \
				mv .sources.new sources ; \
			fi ; \
		else \
			echo "Creating the sources list." ; \
			mv .sources.new sources ; \
		fi ; \
	fi
	@if test -f .sources.new ; then rm -f .sources.new ; fi
	@if test -f .svn/entries ; then svn add sources ; fi

copy-svn-to-cvs : make-upload $(DIST_CVS_BRANCHES_FULL_PATH)

$(DIST_CVS_BRANCHES_FULL_PATH) :
	@cd $(SVN_CHECKOUT_DIR) && \
		( \
		if test -n "$(RUN_TAR_GZ)" ; then \
			ls sources $(SPECFILE) ; \
		else \
			svn list -R . \
			| perl -lne 'BEGIN { @e{qw($(EXISTING_ARCHIVES) Makefile Makefile.dist-cvs dist-cvs-branches branch CVS $(VERSION_FILES) )} = (); } \
				next if exists $$e{$$_}; \
				next if m!/CVS$$!; \
				next if m!/$$!; \
				print;' ; \
		fi \
		) | while read i ; do $(CMP_OR_CP) $$i $@/$$i ; done

	@cd $(SVN_CHECKOUT_DIR) && \
		$(CMP_OR_CP) $(firstword $(findstring version.$(notdir $@),$(VERSION_FILES)) $(VERSION_FILE)) $@/version
	
	@cd $@ && if test -f sources && test -f $(SVN_CHECKOUT_DIR)/sources ; then \
		awk '{print $$2}' sources > .cvsignore.new ; \
		$(CMP_OR_CP) .cvsignore.new .cvsignore ; \
		rm -f .cvsignore.new ; \
		fi

	@cd $@ && if test -f $(SVN_CHECKOUT_DIR)/Makefile.dist-cvs ; then \
		$(CMP_OR_CP) $(SVN_CHECKOUT_DIR)/Makefile.dist-cvs Makefile ; cvs -q add Makefile ; exit 0 ; fi

	@cd $@ && \
		find . -name CVS -prune \
			-o -path ./Makefile -prune \
			-o -path ./branch -prune \
			-o -path ./.cvsignore -prune \
			-o -type f -print \
			| while read i ; do test -f $(SVN_CHECKOUT_DIR)/$$i || ( echo Removing $$i ; rm -rf $$i ; cvs rm $$i ) ; done
	
	cd $@ && cvs diff . ; exit 0

make-build :
	@echo "I will run svn commit,"
	@echo "and cvs commit . && make tag && make build on"
	@for i in $(DIST_CVS_BRANCHES_FULL_PATH) ; do echo "   $$i" ; done
	@echo "now."
	@echo -n "Hit Enter to continue, Ctrl-C to break: " ; read
	svn commit -m "Bugzilla none: Automatic release increase on build: initiating dist-cvs build to $(DIST_CVS_BRANCHES_FULL)." . 
	for i in $(DIST_CVS_BRANCHES_FULL_PATH) ; do \
		cd $$i && cvs commit -m "`echo -e 'Build initiated from Satellite SVN.\nURL: $(SVN_CHECKOUT_URL)\nRevision: $(SVN_CHECKOUT_REVISION)'`" \
		&& $(MAKE) tag && $(MAKE) build ; done

help :
	@if test -n "$(README_FILE)" -a -f "$(README_FILE)" ; then \
		cat $(README_FILE) ; \
		else echo "The README file with help was not found."; fi

prepare-tar-gz :
	@if test -n "$(EXISTING_SRC_RPM)" ; then \
		echo Removing $(EXISTING_SRC_RPM) ; \
		rm -f $(EXISTING_SRC_RPM) ; \
		fi
	@if test -d $(NAME_TAR_GZ_DIR) ; then \
		echo "Removing stale [$(NAME_TAR_GZ_DIR)] prior to tar" ; \
		rm -rf $(NAME_TAR_GZ_DIR) ; \
	fi
	@if test -f $(NAME_TAR_GZ) ; then \
		echo "Removing stale [$(NAME_TAR_GZ)] prior to tar" ; \
		rm -f $(NAME_TAR_GZ) ; \
	fi

tar-gz : prepare-tar-gz
	@mkdir $(NAME_TAR_GZ_DIR) && \
		echo "Creating [$(NAME_TAR_GZ)]" && \
		git archive --format=tar --prefix=$(NAME_TAR_GZ_DIR)/ HEAD | gzip -C - > $(NAME_TAR_GZ)

tar-gz-to-sources : tar-gz
	@$(UPLOAD) $(NAME) $(NAME_TAR_GZ) > sources

wc-tar-gz : prepare-tar-gz
	@mkdir $(NAME_TAR_GZ_DIR) && \
		echo "Creating [$(NAME_TAR_GZ)]" && \
		find . | sed 's!^\./!!' \
			| perl -lne 'BEGIN { @e{qw( $(VERSION_FILE) $(VERSION_FILES) Makefile Makefile.dist-cvs $(TAR_GZ_MAKEFILE_NAME_TEST) $(NAME_TAR_GZ_DIR) dist-cvs-branches sources )} = (); } \
				next if exists $$e{$$_}; \
				print;' \
			| while read file ; do \
			if [ -d $$file ] ; then mkdir -p $(NAME_TAR_GZ_DIR)/$$file ; else ln $$file $(NAME_TAR_GZ_DIR)/$$file ; fi ; \
		done && \
		( test -z "$(TAR_GZ_MAKEFILE_NAME)" || ln $(TAR_GZ_MAKEFILE_NAME) $(NAME_TAR_GZ_DIR)/Makefile ) && \
		tar czf $(NAME_TAR_GZ) $(NAME_TAR_GZ_DIR) && rm -rf $(NAME_TAR_GZ_DIR)

md5sum-tar-gz-to-sources : wc-tar-gz
	@md5sum $(NAME_TAR_GZ) > sources

clear-tar-gz :
	@if test -f $(NAME_TAR_GZ) ; then rm -f $(NAME_TAR_GZ) ; fi

update-changelog :
	@if ! perl -0777 -i -pe 'BEGIN { local $$/ = "\n"; open V, "version" and $$version = <V> ; close V; chomp $$version ; $$version =~ s!\s!-!g; }' \
		-e 'if (not s/(\n%changelog\n\* $(TODAY).+?)\s*(\d\S+)?\n/$$1 $$version\n/) { print ; exit 1 }' $(SPECFILE) ; then \
		echo "Did not find line" ;\
		echo "* $(TODAY) Your Name <youremail@redhat.com> ..." ; \
		echo "as the first line of %changelog -- couldn't update version in changelog." ; \
		exit 1 ; \
	fi

test-rpm : test-srpm
	$(RPMBUILD) $(RPMBUILD_CURDIR) --rebuild -bb *.src.rpm

.PHONY : release test-release test-name test-svn \
	test-cvs test-cvs-branches checkout-cvs \
	test-version bump-version check-keep-version \
	make-upload copy-svn-to-cvs \
	$(DIST_CVS_BRANCHES_FULL_PATH) make-build \
	test-srpm download-sources scratch-build \
	tar-gz-to-sources tar-gz update-changelog \
	md5sum-tar-gz-to-sources wc-tar-gz prepare-tar-gz \
	test-rpm \
	help

