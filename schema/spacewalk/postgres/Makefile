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

STYLE   := postgres
DIRS    := class types tables procs packages views triggers data quartz/tables quartz/data
BLEND   := ../blend -as $(STYLE)
REPLTBS := sed -re "s/\[\[[^]]+\]\]/$(TBS)/g"
MKFILES := $(shell find . -mindepth 2 -maxdepth 2 -name Makefile)


main : tables views data
	$(BLEND) $(DIRS)

devel : main
	$(BLEND) $(DIRS)
	$(REPLTBS) main.sql > devel.sql

tables :
	$(MAKE) -C $@

data :
	$(MAKE) -C $@

views :
	$(MAKE) -C $@

install : main
	sqlplus $(SQLUSER) @main

clean :
	@rm -f main.sql
	@$(foreach m,$(MKFILES),$(MAKE) -C $(dir $(m)) $@;)

.PHONY: clean tables data views
