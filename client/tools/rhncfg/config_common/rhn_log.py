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
import time
import string
import traceback

class Logger:
    debug_level = 1
    logfile = None

    def log_debug(self, debug_level, *args):
        if debug_level <= self.debug_level:
            outstr = "%s %s: %s\n" % (
                time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time())),
                self.get_caller(),
                string.join(map(str, args)))
            sys.stdout.write(outstr)

            if not self.logfile is None:
                self.write_to_logfile(outstr)

    def log_to_file(self, debug_level, *args):
        if debug_level <= self.debug_level:
            outstr = "%s %s: %s\n" % (
                time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time())),
                self.get_caller(),
                string.join(map(str, args)))
            if not self.logfile is None:
                self.write_to_logfile(outstr)
            

    def write_to_logfile(self, logstr):
        if os.access(self.logfile, os.F_OK|os.R_OK|os.W_OK):
            logname = open(self.logfile, "a")
        else:
            #pkilambi: bug#179367: check permissions before writing.
            #non-root users will not have permissions to create the file
            try:
                logname = open(self.logfile, "w")
            except:
                print "does not have permissions to create file  %s" % (self.logfile)
                sys.exit(1)
        logname.write(logstr)
        logname.close()
    
    def set_logfile(self, filename):
        Logger.logfile = filename

    def set_debug_level(self, debug_level):
        Logger.debug_level = debug_level
    
    def get_debug_level(self):
        return Logger.debug_level

    def get_caller(self, caller_offset=4):
        tbStack = traceback.extract_stack()
        callid = len(tbStack) - caller_offset
        module = tbStack[callid]
        module_file = os.path.basename(module[0])
        module_file = string.split(module_file, '.', 1)[0]
        return "%s.%s" % (module_file, module[2])

    def log_error(self, *args):
        line = map(str, args)
        outstr = string.join(line)
        sys.stderr.write(outstr)
        sys.stderr.write("\n")
        if not self.logfile is None:
            self.write_to_logfile(outstr)

    def die(self, error_code, *args):
        self.log_error(args)
        sys.exit(error_code)

def set_debug_level(*args):
    return apply(Logger().set_debug_level, args)

def get_debug_level(*args):
    return apply(Logger().get_debug_level, args)

def set_logfile(*args):
    return apply(Logger().set_logfile, args)

def log_debug(*args):
    return apply(Logger().log_debug, args)

def log_to_file(*args):
    return apply(Logger().log_to_file, args)

def log_error(*args):
    return apply(Logger().log_error, args)

def die(error_code, *args):
    apply(Logger().log_error, args)
    sys.exit(error_code)
