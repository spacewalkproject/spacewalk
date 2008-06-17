#!/bin/bash
#
# Core functions for the iso builder
#
# $Id: build.sh,v 1.3 2003/12/02 22:07:33 misa Exp $

# Source the generic functions
topdir=$(cd $(dirname $0) && pwd)
. $topdir/../build-functions.sh
unset topdir

PRODUCT=proxy
EMAIL_RCPTS=rhn-traffic+proxy-build@redhat.com
DOCS_DIR=proxy/docs
EXTRA_DIRS="upgrade"

main "$@"
