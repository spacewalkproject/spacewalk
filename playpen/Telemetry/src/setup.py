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
                data_files       = [('sample_reports/config', ['/usr/share/telemetry/config/systemDetails.conf', '/usr/share/telemetry/config/affectedSystems.conf', '/usr/share/telemetry/config/relevantErrata.conf']),
                                    ('sample_reports/scripts', ['/usr/share/telemetry/scripts/systemDetailsReport.py', '/usr/share/telemetry/scripts/affectedSystemsReport.py', '/usr/share/telemetry/scripts/relevantErrataReport.py']),
                                    ('sample_reports/templates', ['/usr/share/telemetry/templates/SystemDetails.txt', '/usr/share/telemetry/templates/AffectedSystems.txt', '/usr/share/telemetry/templates/RelevantErrata.txt', '/usr/share/telemetry/templates/RelevantErrata.csv', '/usr/share/telemetry/templates/RelevantErrata.html'])],
	)

