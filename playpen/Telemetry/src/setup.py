#!/usr/bin/env python

from distutils.core import setup
import os

# remove MANIFEST. distutils doesn't properly update it when the contents of directories change.
if os.path.exists('MANIFEST'): os.remove('MANIFEST')

setup(
		name             = 'telemetry',
		version          = '0.1',
		description      = 'Report Engine for Spacewalk.',
		long_description = "Report Manager for XMLRPC data gathering from Spacewalk.",
		author           = 'Todd Sanders',
		author_email     = 'tsanders@redhat.com',
		platforms        = 'linux',
		license          = 'GPLv2',
		py_modules       = [ 'telemetry' ],
		provides         = [ 'telemetry' ],
	)

