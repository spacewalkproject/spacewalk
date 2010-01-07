#
# Copyright (c) 2008--2009 Red Hat, Inc.
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
# Session management
#


import md5
import time
import string

from common import CFG

import rhnSQL

class InvalidSessionError(Exception):
    pass

class ExpiredSessionError(Exception):
    pass

class Session:
    def __init__(self, session_id=None):
        self.session_id = session_id
        self.expires = None
        self.uid = None
        self.duration = None

    def generate(self, duration=None, web_user_id=None):
        # Grabs a session ID
        self.session_id = rhnSQL.Sequence('pxt_id_seq').next()
        self.duration = int(duration or CFG.SESSION_LIFETIME)
        self.web_user_id(web_user_id)
        return self

    def _get_secrets(self):
        # Reads the four secrets from the config file
        return map(lambda x, cfg=CFG: getattr(cfg, 'session_secret_%s' % x),
            range(1, 5))

    def get_secrets(self):
        # Validates the secrets from the config file
        secrets = self._get_secrets()
        if len(secrets) != len(filter(None, secrets)):
            # the list of secrets has unset items
            raise Exception, "Secrets not set in the config file"
        return secrets

    def digest(self):
        if self.session_id is None:
            raise ValueError, "session id not supplied"

        secrets = self.get_secrets()
        
        ctx = md5.new()
        ctx.update(string.join(secrets[:2] + [str(self.session_id)] + 
            secrets[2:], ':'))

        return string.join(map(lambda a: "%02x" % ord(a), ctx.digest()), '')

    def get_session(self):
        return "%sx%s" % (self.session_id, self.digest())

    def web_user_id(self, uid=None):
        if uid:
            self.uid = uid
        return self.uid

    def load(self, session):
        arr = string.split(session, 'x', 1)
        if len(arr) != 2:
            raise InvalidSessionError("Invalid session string")

        digest = arr[1]
        if len(digest) != 32:
            raise InvalidSessionError("Invalid session string (wrong length)")

        try:
            self.session_id = int(arr[0])
        except ValueError:
            raise InvalidSessionError("Invalid session identifier")

        if digest != self.digest():
            raise InvalidSessionError("Bad session checksum")

        h = rhnSQL.prepare("""
            select web_user_id, expires, value
              from pxtSessions
             where id = :session_id
        """)
        h.execute(session_id=self.session_id)

        row = h.fetchone_dict()
        if row:
            # Session is stored in the DB
            if time.time() < row['expires']:
                # And it's not expired yet - good to go
                self.expires = row['expires']
                self.uid = row['web_user_id']
                return self

            # Old session - clean it up
            h = rhnSQL.prepare("""
                DECLARE
                    PRAGMA AUTONOMOUS_TRANSACTION;
                BEGIN
                    delete from pxtSessions where id = :session_id;
                    commit;
                END;
            """)
            h.execute(session_id=self.session_id)

        raise ExpiredSessionError("Session not found")
        

    def save(self):
        expires = int(time.time()) + self.duration

        h = rhnSQL.prepare("""
            DECLARE
                PRAGMA AUTONOMOUS_TRANSACTION;
            BEGIN
                insert into PXTSessions (id, web_user_id, expires, value)
                values (:id, :web_user_id, :expires, :value);
                commit;
            END;
        """)
        h.execute(id=self.session_id, web_user_id=self.uid,
                  expires=expires, value='RHNAPP')
        return self

def load(session_string):
    return Session().load(session_string)

def generate(web_user_id=None, duration=None):
    return Session().generate(web_user_id=web_user_id, duration=duration).save()
