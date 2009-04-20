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
#   dogchow - A common DDL -> oracle DDL generator installed via rpm
#             installed via (yum install dogchow) from fedora extras.
#   genmain - A tool used to process the .deps files to produce
#             the main.sql.  It will inject the contents of a file
#             named "start.sql" at the beginning if it exits.
#
# The build steps are as follows:
#
#   - Populate tables/common from ../common/tables using dogchow.
#   - Populate data/common from ../data/tables using dogchow.
#   - Populate views/common from ../views/tables
#   - Generate the main.sql using genmain.py.
#

ifndef TBS
TBS := users
endif
ifndef SQLUSER
SQLUSER := spacewalk/spacewalk@xe
endif

DOGCHOW := dogchow -FH ../header.txt -s oracle
DIRS    := class types tables procs packages views triggers data
GENMAIN := ../genmain -s oracle  $(DIRS)
REPLTBS := sed -re "s/\[\[[^]]+\]\]/$(TBS)/g"
TMPMAIN := /tmp/main.sql


main : clean tables views data
	$(GENMAIN)
	cp main.sql ../oracle.sql

devel : clean tables views data
	$(GENMAIN)
	$(REPLTBS) main.sql > $(TMPMAIN)
	cp $(TMPMAIN) main.sql

tables : FORCE
	mkdir -p tables/common
	cp ../common/tables/*.deps tables/common
	$(DOGCHOW) -o tables/common ../common/tables/*.sql

views : FORCE
	mkdir views/common
	cp ../common/views/*.deps views/common
	cp ../common/views/*.sql views/common

data : FORCE
	mkdir -p data/common
	cp ../common/data/*.deps data/common
	$(DOGCHOW) -o data/common ../common/data/*.sql

install : main
	sqlplus $(SQLUSER) @main

clean : FORCE
	rm -f main.sql
	rm -rf */common

FORCE:
