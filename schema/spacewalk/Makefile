
include ../../rel-eng/Makefile


# support for
# make satellite-clean satellite-release TBS=USERS SQLUSER=spacewalk/spacewalk@xe 

UNIVERSE := universe.satellite.sql
TOP      := .
SPECFILE := $(firstword $(wildcard *.spec))
NAME     := $(shell rpm -q --qf '%{name}\n' --specfile $(SPECFILE))
VERSION  := $(shell rpm -q --qf '%{version}\n' --specfile $(SPECFILE))
RELEASE  := $(shell rpm -q --qf '%{release}\n' --specfile $(SPECFILE))

spacewalk-clean satellite-clean : schema-make-clean test-make-clean

spacewalk-release satellite-release : schema-make-release test-make-release


%-make-clean :
	$(MAKE) -f $(TOP)/Makefile.$* UNIVERSE=$(UNIVERSE) TOP=$(TOP) SCHEMA=$(NAME) VERSION=$(VERSION) RELEASE=$(RELEASE) clean

%-make-release :
	$(MAKE) -f $(TOP)/Makefile.$* UNIVERSE=$(UNIVERSE) TOP=$(TOP) SCHEMA=$(NAME) VERSION=$(VERSION) RELEASE=$(RELEASE) all

