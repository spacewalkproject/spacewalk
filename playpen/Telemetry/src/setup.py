#!/usr/bin/python

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
                packages         = ['telemetry_web'],
                package_data     = {'telemetry_web': ['templates/*.html']},
                data_files       = [('/usr/share/telemetry/config', ['sample_reports/config/systemDetails.conf', 'sample_reports/config/affectedSystems.conf', 'sample_reports/config/relevantErrata.conf', 'sample_reports/config/systemsByPackage.conf']),
                                    ('/usr/share/telemetry/scripts', ['sample_reports/scripts/systemDetailsReport.py', 'sample_reports/scripts/affectedSystemsReport.py', 'sample_reports/scripts/relevantErrataReport.py', 'sample_reports/scripts/systemsByPackageReport.py']),
                                    ('/usr/share/telemetry/templates', ['sample_reports/templates/SystemDetails.txt', 'sample_reports/templates/AffectedSystems.txt', 'sample_reports/templates/RelevantErrata.txt', 'sample_reports/templates/RelevantErrata.csv', 'sample_reports/templates/RelevantErrata.html', 'sample_reports/templates/SystemsByPackage.txt']),
                                    ('/usr/bin', ['telemetry']),
                                    ('/etc/telemetry', ['telemetry.conf']),
                                    ('/etc/telemetry', ['sudoers.telemetry']),
                                    ('/etc/httpd/conf.d', ['telemetry_web/telemetry.conf'])]

	)
