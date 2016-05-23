# Client code for Update Agent
# Copyright (c) 2011--2016 Red Hat, Inc.  Distributed under GPLv2.
#
# Author: Simon Lukasik

from up2date_client.pkgplatform import getPlatform

if getPlatform() == 'deb':
    from up2date_client.debUtils import *
else:
    from up2date_client.rpmUtils import *

