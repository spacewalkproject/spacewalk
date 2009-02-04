#!/usr/bin/python
#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

import os
import sys
import string
import ModeControllerCreator
from optparse import Option, OptionParser


def main():
    optionsTable = [
        Option('--enable-deploy',       action='store_true',      help='Allow rhncfg-client to deploy files.', default=0),
        Option('--enable-diff',         action='store_true',      help='Allow rhncfg-client to diff files.', default=0),
        Option('--enable-upload',       action='store_true',      help='Allow rhncfg-client to upload files.', default=0),
        Option('--enable-mtime-upload', action='store_true',      help='Allow rhncfg-client to upload mtime.', default=0),
        Option('--enable-run',          action='store_true',      help='Allow rhncfg-client the ability to execute remote scripts.', default=0),
        Option('--enable-all',          action='store_true',      help='Allow rhncfg-client to do everything.', default=0),
        Option('--disable-deploy',      action='store_true',      help='Disable deployment.', default=0),
        Option('--disable-diff',        action='store_true',      help='Disable diff.', default=0),
        Option('--disable-upload',      action='store_true',      help='Disable upload.', default=0),
        Option('--disable-mtime-upload',action='store_true',      help='Disable mtime upload.', default=0),
        Option('--disable-run',         action='store_true',      help='Disable remote script execution.', default=0),
        Option('--disable-all',         action='store_true',      help='Disable all options.', default=0),
        Option('-f', '--force',         action='store_true',      help='Force the operation without confirmation', default=0),
        Option('--report',              action='store_true',      help='Report the status of the mode settings (enabled or disabled)', default=0),
    ]

    parser = OptionParser(option_list=optionsTable)
    (options, args) = parser.parse_args()

    creator = ModeControllerCreator.get_controller_creator()
    controller = creator.create_controller()
    controller.set_force(options.force)

    runcreator = ModeControllerCreator.get_run_controller_creator()
    runcontroller = runcreator.create_controller()
    runcontroller.set_force(options.force)    

    if options.enable_deploy:
        controller.on('deploy')

    if options.enable_diff:
        controller.on('diff')
    
    if options.enable_upload:
        controller.on('upload')

    if options.enable_mtime_upload:
        controller.on('mtime_upload')

    if options.enable_all:
        controller.all_on()
        runcontroller.all_on()

    if options.enable_run:
        runcontroller.on('run')

    if options.disable_deploy:
        controller.off('deploy')

    if options.disable_diff:
        controller.off('diff')

    if options.disable_upload:
        controller.off('upload')

    if options.disable_mtime_upload:
        controller.off('mtime_upload')

    if options.disable_all:
        controller.all_off()
        runcontroller.all_off()
    
    if options.disable_run:
        runcontroller.off('run')

    if options.report:
        mode_list = ['deploy', 'diff', 'upload', 'mtime_upload']
        
        for m in mode_list:
            rstring = "%s is %s"
            status = "disabled"
            if controller.is_on(m):
                status = "enabled"
            print rstring % (m, status)
        
        status = "disabled"
        if runcontroller.is_on('run'):
            status = "enabled"
        print rstring % ('run', status)
           
        
if __name__ == "__main__":
    try:
        sys.exit(main() or 0)
    except KeyboardInterrupt:
        sys.stderr.write("user interrupted\n")
        sys.exit(0)

