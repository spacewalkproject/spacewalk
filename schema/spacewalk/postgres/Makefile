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
#   dogchow - A common DDL -> postgres DDL generator installed via rpm
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

ifndef SQLUSER
SQLUSER := spacewalk
endif

DOGCHOW := dogchow -FH ../header.txt -s postgres -O best
DIRS    := class types tables procs packages views triggers data
GENMAIN := ../../util/genmain -s postgres $(DIRS)

main : clean tables views data
	$(GENMAIN)

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
	psql -d $(SQLUSER) -f main.sql -v ON_ERROR_STOP=

clean : FORCE
	rm -f main.sql
	rm -rf */common

FORCE:
