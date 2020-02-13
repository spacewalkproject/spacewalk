#
# Copyright (c) 2008--2013 Red Hat, Inc.
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

import sys
try:
    # Python 2
    import commands
except ImportError:
    import subprocess as commands

from spacewalk.common.usix import StringType
from distutils.sysconfig import get_python_lib

COMMAND = "python%s %s/virtualization/poller.py" % (sys.version[0], get_python_lib())

def create_crontab_line(minute  =   None,\
                        hour    =   None,\
                        dom     =   None,\
                        month   =   None,\
                        dow     =   None,
                        command =   COMMAND):
    user = "root"

    if minute == None:
        minute = "*"
    if hour == None:
        hour = "*"
    if dom == None:
        dom = "*"
    if month == None:
        month = "*"
    if dow == None:
        dow = "*"

    if type(minute) != StringType:
        minute = str(minute).strip()
    if type(hour) != StringType:
        hour = str(hour).strip()
    if type(dom) != StringType:
        dom = str(dom).strip()
    if type(month) != StringType:
        month = str(month).strip()
    if type(dow) != StringType:
        dow = str(dow).strip()

    str_template = "%s %s %s %s %s %s %s\n"

    output_string = str_template % (minute, hour, dom, month, dow, user, command)
    return output_string


def schedule_poller(minute=None, hour=None, dom=None, month=None, dow=None):
    try:
        #create a crontab file
        filename = "/etc/cron.d/rhn-virtualization.cron"
        cronfile = open(filename, "w")

        #create a crontab line
        cron_line = create_crontab_line(minute, hour, dom, month, dow)

        #write crontab line to the temp file
        cronfile.write(cron_line)

        #close the temp file
        cronfile.close()

    except Exception:
        e = sys.exc_info()[1]
        return (1, str(e))

    #pass the temp file to crontab
    status, output = commands.getstatusoutput("/sbin/service crond restart")

    if status != 0:
        return (1, "Attempt to schedule poller failed: %s, %s" % (str(status), str(output)))
    else:
        return (0, "Scheduling of poller succeeded!")



if __name__ == "__main__":
    schedule_poller(minute="0-59/2")



