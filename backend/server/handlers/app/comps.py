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
# comps mgmt functions
# This is the XML-RPC response handler for manage-comps tool


from common import RPC_Base, rhnFault
from server import rhnSQL
from server.importlib.userAuth import UserAuth


class Comps(RPC_Base):

    def __init__(self):
        RPC_Base.__init__(self)        
        
        self.functions = ['addComps']
        
    def _auth(self, username, password):

        if not (username and password):
            raise rhnFault(50, "Missing username/password arguments",
                explain=0)

        authobj = auth(username, password)

        if not authobj:
            raise rhnFault(50, "Invalid username/password arguments",
                                           explain=0)
        return authobj

    def addComps(self, username, password, channel_id, file_name):
        authobj = self._auth(username, password)
        authobj.isChannelAdmin()
        
        sql_stmt = rhnSQL.prepare("""
        insert into rhnChannelComps
            (id, channel_id, relative_filename)
        values (sequence_nextval('rhn_channelcomps_id_seq'),
                :channel_id,
                :relative_filename)
        """)
        
        sql_stmt.execute(channel_id = channel_id, 
            relative_filename = file_name)

        rhnSQL.commit()
        message = 'Success. Committing transaction.'
        return message

def auth(login, password):
    # Authorize this user
    authobj = UserAuth()
    authobj.auth(login, password)
    return authobj

