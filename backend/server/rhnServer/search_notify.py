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
# Sends notification to search-server that it should update server index
#

import sys
import xmlrpclib
try:
    from common import log_error
except:
    sys.path.append("/usr/share/rhn")
    from common import log_error

class SearchNotify:
    def __init__(self, host="127.0.0.1", port="2828"):
        self.addr = "http://%s:%s" % (host, port)

    def notify(self, indexName="server"):
        try:
            client = xmlrpclib.ServerProxy(self.addr)
            result = client.admin.updateIndex(indexName)
        except Exception, e:
            log_error("Failed to notify search service located at %s to update %s indexes" \
                    % (self.addr, indexName), e)
            return False
        return result

if __name__ == "__main__":
    search = SearchNotify()
    result = search.notify()
    print "search.notify() = %s" % (result)
