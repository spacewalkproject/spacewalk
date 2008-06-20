
NAME := rhn-web

SPECFILE = $(NAME).spec
DO_TAR_GZ := git-tree-sha1
TAR_GZ_MAKEFILE_NAME := Makefile.rhn-web
 
include ../rel-eng/Makefile

local-srpm:
	./buildsrpm.sh
