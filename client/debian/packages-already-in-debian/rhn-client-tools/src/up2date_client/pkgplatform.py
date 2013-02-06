# Client code for Update Agent
# Copyright (c) 2011--2012 Red Hat, Inc.  Distributed under GPLv2.
#
# Author: Simon Lukasik
#

# substituted to the prefered platfrom by Makefile
_platform='@PLATFORM@'
def getPlatform():
    if _platform != '@PLAT' + 'FORM@':
        return _platform
    else:
        return 'rpm'

