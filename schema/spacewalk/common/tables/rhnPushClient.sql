--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
--
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation.
--


CREATE TABLE rhnPushClient
(
    id                 NUMBER NOT NULL
                           CONSTRAINT rhn_pclient_id_pk PRIMARY KEY
                           USING INDEX TABLESPACE [[4m_tbs]],
    name               VARCHAR2(64) NOT NULL,
    server_id          NUMBER NOT NULL,
    jabber_id          VARCHAR2(128),
    shared_key         VARCHAR2(64) NOT NULL,
    state_id           NUMBER NOT NULL
                           REFERENCES rhnPushClientState (id),
    next_action_time   DATE,
    last_message_time  DATE,
    last_ping_time     DATE,
    created            DATE
                           DEFAULT (sysdate) NOT NULL,
    modified           DATE
                           DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_pclient_name_uq
    ON rhnPushClient (name)
    TABLESPACE [[8m_tbs]];

CREATE UNIQUE INDEX rhn_pclient_sid_uq
    ON rhnPushClient (server_id)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_pclient_id_seq;

