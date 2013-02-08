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

from templated_document import ServerTemplatedDocument
from spacewalk.server import rhnServer, rhnSQL

rhnSQL.initDB()

server_id = 1003887108

server = rhnServer.search(server_id)
server.reload_hardware()
server.load_custom_info()

t = ServerTemplatedDocument(server, start_delim='@@', end_delim='@@')
#t = ServerTemplatedDocument(server, start_delim='{|', end_delim='|}')

data = open("test/template1.tmpl").read()

try:
    print "interpolated:  ", t.interpolate(data)
except Exception, e:
    print e
    tb = sys.exc_info()[2]
    stack = []
    # walk the traceback to the end
    while 1:
        if not tb.tb_next:
            break
        tb = tb.tb_next
    # and now start extracting the stack frames
    f = tb.tb_frame
    while f:
        stack.append(f)
        f = f.f_back

    for frame in stack:
        print "Frame %s in %s at line %s\n" % (frame.f_code.co_name,
                                               frame.f_code.co_filename,
                                               frame.f_lineno)

        for key, value in frame.f_locals.items():
            message = "\t%20s = " % key
            try:
                s = str(value)
            except:
                s = "<ERROR WHILE PRINTING VALUE>"
            if len(s) > 100 * 1024:
                s = "<ERROR WHILE PRINTING VALUE: string representation too large>"
            print message + s
