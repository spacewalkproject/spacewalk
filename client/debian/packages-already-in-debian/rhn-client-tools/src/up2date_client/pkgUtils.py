# Client code for Update Agent
# Copyright (c) 2011--2012 Red Hat, Inc.  Distributed under GPLv2.
#
# Author: Simon Lukasik

from pkgplatform import getPlatform

if getPlatform() == 'deb':
    from debUtils import *
else:
    from rpmUtils import *

