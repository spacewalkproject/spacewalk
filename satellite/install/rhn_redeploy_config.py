#!/usr/bin/python -u
""" redeploy RHN Satellite configuration files
    Useful for migrating settings from one version of RHN Satellite to another
    version.

    Copyright (c) 2004-2005 Red Hat, Inc.
    All rights reserved.

    Author: Todd Warner <taw@redhat.com>
"""
#-------------------------------------------------------------------------------
# $Id: rhn_redeploy_config.py,v 1.4 2005-07-05 17:50:13 wregglej Exp $

## language imports
import os
import sys
import string


#sys.path.append("@@ROOT@@")
executionPath = os.path.dirname(sys.argv[0])
if executionPath not in sys.path:
    sys.path.append(executionPath)

try:
    import satConfig
except ImportError, e:
    sys.stderr.write("Unable to load module satConfig.py\n")
    sys.stderr.write(str(e) + "\n")
    sys.exit(1)


#-------------------------------------------------------------------------------
if __name__ == '__main__':
    # exits with 100 on ^C
    # check satConfig.py for other exit codes
    try:
        sys.exit(satConfig.redeploy() or 0)
    except KeyboardInterrupt, e:
        sys.stderr.write("\nUser interrupted process.\n")
        sys.exit(100)
    except SystemExit, e:
        sys.exit(e.code)
    except Exception, e:
        sys.stderr.write("\nERROR: unhandled exception occurred:\n")
        raise
#===============================================================================

