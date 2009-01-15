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
# this module implements the send mail support
#

import os
import sys
import string

from rhnConfig import CFG
from rhnLog import log_error

# check if the headers have the minimum required fields
def __check_headers(h):
    if type(h) != type({}) or not hasattr(h, "has_key"):
        # does not look like a dictionary
        h = {}
    if not h.has_key("Subject"):
        h["Subject"] = "RHN System Mail From %s" % os.uname()[1]
    if not h.has_key("To"):
        to = CFG.TRACEBACK_MAIL
    else:
        to = h["To"]
    if type(to) in [type([]), type(())]:
        to = string.join(to, ', ')
    h["To"] = to
    return h

# check the headers for sanity cases and send the mail
def send(headers, body, sender = None, lazy = 0):
    headers = __check_headers(headers)

    sendmail = "/usr/sbin/sendmail"
    cmds = ["sendmail", "-oi", "-t"]
    if sender:
        cmds.append("-f%s" % sender)
    if lazy:
        cmds.append("-ODeliveryMode=q")
        
    (read, write) = os.pipe()
    childpid = os.fork()
    if childpid < 0: # fork failed
        log_error("ERROR: fork of sendmail process failed.\nAlert being sent:\n%s" % body)
        return -1
    if childpid == 0:
        # in the child
        os.dup2(read, 0)
        os.close(write)
        os.execv(sendmail, cmds)
        # not reached
        sys.exit(1)
    # main process
    os.close(read)
    # Now write the message out
    keys = headers.keys()
    keys.sort()
    for h in keys:
        os.write(write, "%s: %s\n" % (h, headers[h]))
    os.write(write, "\n%s\n" % body)
    os.close(write)
    # clean up
    (pid, status) = os.waitpid(childpid, 0)    
    return status
