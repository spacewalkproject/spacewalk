#
# Copyright (c) 2008--2015 Red Hat, Inc.
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
import smtplib

from rhnConfig import CFG, PRODUCT_NAME
from rhn.connections import idn_puny_to_unicode
from stringutils import to_string

# check if the headers have the minimum required fields


def __check_headers(h):
    if not isinstance(h, type({})) or not hasattr(h, "has_key"):
        # does not look like a dictionary
        h = {}
    if not h.has_key("Subject"):
        h["Subject"] = "%s System Mail From %s" % (PRODUCT_NAME,
                                                   idn_puny_to_unicode(os.uname()[1]))
    if not h.has_key("To"):
        to = CFG.TRACEBACK_MAIL
    else:
        to = h["To"]
    if not ("Content-Type" in h):
        h["Content-Type"] = "text/plain; charset=utf-8"
    if isinstance(to, (type([]), type(()))):
        toaddrs = to
        to = ', '.join(to)
    else:
        toaddrs = to.split(',')
    h["To"] = to
    return [h, toaddrs]

# check the headers for sanity cases and send the mail


def send(headers, body, sender=None):
    (headers, toaddrs) = __check_headers(headers)
    if sender is None:
        sender = headers["From"]
    joined_headers = u''
    for h in headers.keys():
        joined_headers += u"%s: %s\n" % (h, headers[h])

    server = smtplib.SMTP('localhost')
    msg = "%s\n%s\n" % (to_string(joined_headers), to_string(body))
    server.sendmail(sender, toaddrs, msg)
    server.quit()
