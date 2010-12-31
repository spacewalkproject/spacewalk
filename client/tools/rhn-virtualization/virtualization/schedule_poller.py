#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
sys.path.append("/usr/share/rhn")
import string
import types
import commands

def create_crontab_line(minute  =   None,\
                        hour    =   None,\
                        dom     =   None,\
                        month   =   None,\
                        dow     =   None,
                        command =   "python /usr/share/rhn/virtualization/poller.py"):
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

    if type(minute) != types.StringType:
        minute = string.strip(str(minute))
    if type(hour) != types.StringType:
        hour = string.strip(str(hour))
    if type(dom) != types.StringType:
        dom = string.strip(str(dom))
    if type(month) != types.StringType:
        month = string.strip(str(month))
    if type(dow) != types.StringType:
        dow = string.strip(str(dow))
    
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

    except Exception, e:
        return (1, str(e))

    #pass the temp file to crontab
    status, output = commands.getstatusoutput("/sbin/service crond restart")

    if status != 0:
        return (1, "Attempt to schedule poller failed: %s, %s" % (str(status), str(output)))
    else:
        return (0, "Scheduling of poller succeeded!")
    


if __name__ == "__main__":
    schedule_poller(minute="0-59/2")    
    
    
    
