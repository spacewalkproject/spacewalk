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
ifndef COMMON
COMMON := ../../../common
$(warning COMMON not defined, using $(COMMON))
endif
ifndef NAME
NAME := $(notdir $(shell cd ../; pwd))
endif

SRCDIR    := $(shell find $(COMMON) -name $(NAME))
SOURCES   := $(wildcard $(SRCDIR)/*)
FILES     := $(notdir $(SOURCES))
CHAMELEON := chameleon -fs $(STYLE) $(CFLAGS)
RMLINKS   := find . -type l -delete
RMTRASH   := rm -f lextab* parsetab* parser.out


all : links
	$(MAKE) $(MAKEOVERRIDES) files

files : $(FILES)
	@$(RMTRASH)

%.sql : %.cql
	$(CHAMELEON) -o $@ $^

links :
	@$(RMLINKS)
	@$(foreach f,$(SOURCES),ln -s $f $(notdir $(f:.sql=.cql));)

.PHONY : links
