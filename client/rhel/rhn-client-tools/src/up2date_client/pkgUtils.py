# Client code for Update Agent
# Copyright (c) 2011 Red Hat, Inc.  Distributed under GPL.
#
# Author: Simon Lukasik

from platform import getPlatform

if getPlatform() == 'deb':
    from debUtils import *
else:
    from rpmUtils import *

