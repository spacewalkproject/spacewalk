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

ifndef COMMON
COMMON  := ../../../common
endif
ifndef NAME
NAME  := $(notdir $(shell pwd))
endif

SOURCES := $(notdir $(wildcard $(COMMON)/$(NAME)/*))


common : clean
	@mkdir -p common
	@cp Makefile common
	@$(MAKE) -C common NAME=$(NAME) links

links : $(SOURCES)

%.sql %.deps :
	@ln -s $(COMMON)/$(NAME)/$@ .

clean :
	@rm -rf common

.PHONY: clean common
