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
# Class for handling and updating the server history.
#

from spacewalk.common.rhnLog import log_debug
from spacewalk.server import rhnSQL

# these are kind of out there...
MAX_SUMMARY = 128
MAX_DETAILS = 4000


class History:

    def __init__(self):
        self.__h = []

    def add_history(self, summary, details=""):
        """ Add a history event to the server. """
        log_debug(4, summary)
        if details == '':
            self.__h.append((summary[:MAX_SUMMARY], None))
        else:
            self.__h.append((summary[:MAX_SUMMARY], details[:MAX_DETAILS]))

    def save_history_byid(self, server_id):
        log_debug(3, server_id, "%d history events" % len(self.__h))
        if not self.__h:
            return 0
        hist = rhnSQL.prepare("""
            insert into rhnServerHistory
                (id,
                 server_id,
                 summary,
                 details)
            values
                (sequence_nextval('rhn_event_id_seq'),
                 :server_id,
                 :summary,
                 :details)
        """)
        summaries = [x[0] for x in self.__h]
        details = [x[1] for x in self.__h]
        server_ids = [server_id] * len(self.__h)
        hist.executemany(server_id=server_ids, summary=summaries,
                         details=details)
        # Clear the history cache
        self.__h = []
        return 0
