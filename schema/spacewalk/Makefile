include ../../rel-eng/Makefile

TOP      := .
SPECFILE := $(firstword $(wildcard *.spec))
NAME     := $(shell rpm -q --qf '%{name}\n' --specfile $(SPECFILE))
VERSION  := $(shell rpm -q --qf '%{version}\n' --specfile $(SPECFILE))
RELEASE  := $(shell rpm -q --qf '%{release}\n' --specfile $(SPECFILE))

spacewalk-clean satellite-clean : FORCE
	$(MAKE) -f $(TOP)/Makefile.schema clean

spacewalk-release satellite-release : FORCE
	$(MAKE) -f $(TOP)/Makefile.schema SCHEMA=$(NAME) VERSION=$(VERSION) RELEASE=$(RELEASE) all

FORCE :
