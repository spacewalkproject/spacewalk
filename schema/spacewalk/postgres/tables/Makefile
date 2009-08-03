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

COMMON := ../../common
FLAGS  := STYLE=postgres COMMON=../$(COMMON) CFLAGS="-O best"

common :
	@mkdir -p common
	@cp $(COMMON)/Makefile common
	@$(MAKE) -C common $(FLAGS) $(MAKEOVERRIDES)

clean :
	@rm -rf common

.PHONY : common clean
