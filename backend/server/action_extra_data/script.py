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
#

import base64

from spacewalk.common.rhnLog import log_debug
from spacewalk.server import rhnSQL

# the "exposed" functions
__rhnexport__ = ['run']

_query_clear_output = rhnSQL.Statement("""
delete from rhnServerActionScriptResult
 where server_id = :server_id
   and action_script_id = (
     select id from rhnActionScript where action_id = :action_id
   )
""")

_query_initial_store = rhnSQL.Statement("""
insert into rhnServerActionScriptResult (
    server_id,
    action_script_id,
    output,
    start_date,
    stop_date,
    return_code
  )
values (
       :server_id,
       (select ascript.id
          from rhnActionScript ascript
         where ascript.action_id = :action_id),
       :output,
       TO_TIMESTAMP(:process_start, 'YYYY-MM-DD HH24:MI:SS'),
       TO_TIMESTAMP(:process_end, 'YYYY-MM-DD HH24:MI:SS'),
       :return_code)
""")

def run(server_id, action_id, data={}):
    log_debug(3)

    # clear any previously received output
    h = rhnSQL.prepare(_query_clear_output)
    h.execute(server_id=server_id, action_id=action_id)
    
    if not data:
        log_debug(4, "No data sent by client")
        return

    output = data.get('output')

    # newer clients should always be setting
    # this flag and encoding the results,
    # otherwise xmlrpc isn't very happy on certain characters
    if data.has_key('base64enc'):
        output = base64.decodestring(output)
    
    return_code = data.get('return_code')
    process_end = data.get('process_end')
    process_start = data.get('process_start')

    log_debug(4, "script output", output)

    h = rhnSQL.prepare(_query_initial_store, blob_map={'output': 'output'})
    h.execute(server_id=server_id,
              action_id=action_id,
              process_start=process_start,
              process_end=process_end,
              return_code=return_code,
              output=output
              )

