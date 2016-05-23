#
# Copyright (c) 2008--2016 Red Hat, Inc.
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

import PAM
import sys

from spacewalk.common.usix import raise_with_tb
from spacewalk.common.rhnLog import log_error
from spacewalk.common.rhnException import rhnException

__username = None
__password = None


def __pam_conv(auth, query_list):
    global __username, __password
    # Build a list of responses to be passed back to PAM
    resp = []
    for query, type in query_list:
        if type == PAM.PAM_PROMPT_ECHO_ON:
            # Prompt for a username
            resp.append((__username, 0))
        elif type == PAM.PAM_PROMPT_ECHO_OFF:
            # Prompt for a password
            resp.append((__password, 0))
        else:
            # Unknown PAM type
            log_error("Got unknown PAM type %s (query=%s)" % (type, query))
            return None

    return resp


def check_password(username, password, service):
    global __username, __password
    auth = PAM.pam()
    auth.start(service, username, __pam_conv)

    # Save the username and passwords in the globals, the conversation
    # function needs access to them
    __username = username
    __password = password

    try:
        try:
            auth.authenticate()
            auth.acct_mgmt()
        finally:
            # Something to be always executed - cleanup
            __username = __password = None
    except PAM.error:
        e = sys.exc_info()[1]
        resp, code = e.args[:2]
        log_error("Password check failed (%s): %s" % (code, resp))
        return 0
    except:
        raise_with_tb(rhnException('Internal PAM error'), sys.exc_info()[2])
    else:
        # Good password
        return 1
