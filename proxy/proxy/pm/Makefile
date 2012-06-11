# Makefile for the PackageManager modules
#
# $Id: Makefile,v 1.15 2004/01/08 01:40:24 taw Exp $

TOP	= ..
SUBDIR  = PackageManager
FILES	= rhn_package_manager __init__
MAN_BASE = rhn_package_manager
MAN_SECT = 8
DOCBOOK2MAN = /usr/bin/docbook2man
MAN_DIR	= $(PREFIX)/usr/share/man/man$(MAN_SECT)
PM_BIN_DIR  = $(PREFIX)/usr/bin

SUBDIRS	= rhn-conf

all ::	all-man

install:: install-man install-bin

clean :: clean-man

all-man: make-man

make-man: $(MAN_BASE).$(MAN_SECT).gz

$(MAN_BASE).$(MAN_SECT): $(MAN_BASE).sgml
	$(DOCBOOK2MAN) $<

$(MAN_BASE).$(MAN_SECT).gz: $(MAN_BASE).$(MAN_SECT)
	gzip -c $< > $@

install-man: make-man $(MAN_DIR)
	$(INSTALL_DATA) $(MAN_BASE).$(MAN_SECT).gz $(MAN_DIR)

install-bin: rhn_package_manager $(PM_BIN_DIR)
	$(INSTALL_BIN) rhn_package_manager $(PM_BIN_DIR)

$(MAN_DIR) $(PM_BIN_DIR):
	$(INSTALL_DIR) $@

clean-man:
	@rm -fv $(MAN_BASE).8 $(MAN_BASE).8.gz manpage.links manpage.refs

include $(TOP)/Makefile.defs
