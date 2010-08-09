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
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#
# Make used to build the oracle schema.
#
# Arguments:
#
#   SQLUSER - The sqlplus connect information.
#             (default: spacewalk/spacewalk@xe).
#   TBS     - The name of the tablespace to be used to replace the
#             [[ tbs ]] macros found in the DDL.  It is intended that
#             this be specified only for development installs.
#             (default: users).
#   
# It uses the following tools:
#
#   blend    - A tool used to process the .deps files to produce
#              the main.sql.  It will inject the contents of a file
#              named "start.sql" at the beginning if it exits.
#

ifndef TBS
TBS := users
endif
ifndef SQLUSER
SQLUSER := spacewalk/spacewalk@xe
endif

STYLE   := oracle
DIRS    := class types tables procs packages views triggers data synonyms quartz/tables quartz/data
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
