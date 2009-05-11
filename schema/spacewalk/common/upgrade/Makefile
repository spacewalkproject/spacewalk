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

ifndef STYLE
STYLE := oracle
$(warning STYLE not defined, using $(STYLE))
endif

ROOT    := ../../..
UPGRADE := $(notdir $(shell pwd))
COMMON  := $(ROOT)/common
FLAGS   := STYLE=$(STYLE) COMMON=../$(COMMON)
BLEND   := $(ROOT)/blend -as $(STYLE)

$(UPGRADE).sql : common
	$(BLEND) -o $@
	cp $@ ../

common :
	@mkdir -p common
	@cp $(COMMON)/Makefile common
	@$(MAKE) -C common $(FLAGS) $(MAKEOVERRIDES)

clean :
	@rm -rf common
	@rm -f $(UPGRADE).sql

.PHONY : common clean
