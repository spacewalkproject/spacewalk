
THIS_MAKEFILE := $(realpath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(dir $(THIS_MAKEFILE))

SPACEWALK_BUILD_RC := ~/.spacewalk-build-rc
ifneq (,$(wildcard $(SPACEWALK_BUILD_RC)))
SPACEWALK_BUILD_RC_FILE := $(wildcard $(SPACEWALK_BUILD_RC))
include $(SPACEWALK_BUILD_RC_FILE)
endif

README_FILE = $(wildcard $(THIS_DIR)README)

PACKAGES_DIR := $(THIS_DIR)packages/

ifndef SPECFILE
SPECFILE := $(firstword $(wildcard *.spec))
endif

ifndef NAME
ifdef SPECFILE
NAME := $(shell rpm -q --qf '%{name}\n' --define "_sourcedir $(CURDIR)" --specfile $(SPECFILE) | head -1)
endif
endif

HEAD_COMMIT_SHA1 := $(shell git rev-parse --verify HEAD 2> /dev/null)

ifneq (,$(HEAD_COMMIT_SHA1))
GIT_PREFIX = $(shell git rev-parse --show-prefix)
GIT_CDUP := $(shell git rev-parse --show-cdup )
ifeq (,$(GIT_CDUP))
GIT_CDUP := ./
endif
endif

help :
	@if test -n "$(README_FILE)" -a -f "$(README_FILE)" ; then \
		cat $(README_FILE) ; \
		else echo "The README file with help was not found."; fi

debug :
	@echo "THIS_MAKEFILE [$(THIS_MAKEFILE)]"
	@echo "THIS_DIR [$(THIS_DIR)]"
	@echo "SPACEWALK_BUILD_RC [$(SPACEWALK_BUILD_RC)]"
	@echo "SPACEWALK_BUILD_RC_FILE [$(SPACEWALK_BUILD_RC_FILE)]"
	@echo "README_FILE [$(README_FILE)]"
	@echo "PACKAGES_DIR [$(PACKAGES_DIR)]"
	@echo "SPECFILE [$(SPECFILE)]"
	@echo "NAME [$(NAME)]"
	@echo "DIR [$(DIR)]"
	@echo "HEAD_COMMIT_SHA1 [$(HEAD_COMMIT_SHA1)]"
	@echo "GIT_PREFIX [$(GIT_PREFIX)]"
	@echo "GIT_CDUP [$(GIT_CDUP)]"
	@echo "VERSION_FILE [$(VERSION_FILE)]"
	@echo "BUMP_VERSION_FILE_OPTIONS [$(BUMP_VERSION_FILE_OPTIONS)]"
	@echo "KEEP_VERSION [$(KEEP_VERSION)]"
	@echo "BUMP_VERSION [$(BUMP_VERSION)]"
	@echo "BUMP_RELEASE [$(BUMP_RELEASE)]"
	@echo "CURRENT_VERSION [$(CURRENT_VERSION)]"
	@echo "USER_NAME [$(USER_NAME)]"
	@echo "TODAY [$(TODAY)]"
	@echo "RPMBUILD [$(RPMBUILD)]"
	@echo "RPMBUILD_BASEDIR [$(RPMBUILD_BASEDIR)]"
	@echo "X_RPMBUILD_DIR [$(X_RPMBUILD_DIR)]"
	@echo "X_RPMBUILD_DIR_OPTS [$(X_RPMBUILD_DIR_OPTS)]"
	@echo "DIST [$(DIST)]"
	@echo "DIST_OPTS [$(DIST_OPTS)]"
	@echo "TAG [$(TAG)]"
	@echo "TAG_SHA1 [$(TAG_SHA1)]"
	@echo "COMMIT [$(COMMIT)]"
	@echo "COMMIT_SHA1 [$(COMMIT_SHA1)]"
	@echo "NAME_TAR_GZ_DIR [$(NAME_TAR_GZ_DIR)]"
	@echo "COMMIT_TIMESTAMP [$(COMMIT_TIMESTAMP)]"
	@echo "RPMBUILD_SOURCEDIR [$(RPMBUILD_SOURCEDIR)]"
	@echo "NAME_TAR_GZ [$(NAME_TAR_GZ)]"
	@echo "RPMBUILD_DIR [$(RPMBUILD_DIR)]"

x-debug :
	$(MAKE) debug

include $(THIS_DIR)Makefile.tag-release

include $(THIS_DIR)Makefile.srpm

.PHONY: help debug

