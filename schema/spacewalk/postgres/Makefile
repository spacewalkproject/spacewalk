#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Make used to build the postgres schema.
#
# Arguments:
#
#   SQLUSER - The psql connect information.
#             (default: spacewalk).
#
# It uses the following tools:
#
#   blend    - A tool used to process the .deps files to produce
#              the main.sql.  It will inject the contents of a file
#              named "start.sql" at the beginning if it exits.
#

ifndef SQLUSER
SQLUSER := spacewalk
endif

DIRS    := class types tables procs packages views triggers data
BLEND   := ../blend -as postgres
MKFILES := $(shell find . -mindepth 2 -name Makefile)


main : tables views data upgrade
	$(BLEND) $(DIRS)

devel : main
	$(BLEND) $(DIRS)
	$(REPLTBS) main.sql > devel.sql

tables : FORCE
	$(MAKE) -C $@/common

data : FORCE
	$(MAKE) -C $@/common

views : FORCE
	$(MAKE) -C $@/common

upgrade : FORCE
	$(MAKE) -C $@

install : main
	sqlplus $(SQLUSER) @main

clean : FORCE
	@rm -f main.sql
	@$(foreach m, $(MKFILES), $(MAKE) -C $(dir $(m)) $@;)

FORCE:
