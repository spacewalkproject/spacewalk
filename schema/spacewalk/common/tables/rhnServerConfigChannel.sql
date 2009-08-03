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


CREATE TABLE rhnServerConfigChannel
(
    server_id          NUMBER NOT NULL
                           CONSTRAINT rhn_servercc_sid_fk
                               REFERENCES rhnServer (id),
    config_channel_id  NUMBER NOT NULL
                           CONSTRAINT rhn_servercc_ccid_fk
                               REFERENCES rhnConfigChannel (id)
                               ON DELETE CASCADE,
    position           NUMBER,
    created            DATE
                           DEFAULT (sysdate) NOT NULL,
    modified           DATE
                           DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_servercc_sid_ccid_uq
    ON rhnServerConfigChannel (server_id, config_channel_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_servercc_ccid_idx
    ON rhnServerConfigChannel (config_channel_id)
    TABLESPACE [[2m_tbs]];

