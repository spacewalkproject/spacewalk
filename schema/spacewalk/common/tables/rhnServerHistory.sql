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


CREATE TABLE rhnServerHistory
(
    id         NUMBER NOT NULL
                   CONSTRAINT rhn_serverhistory_id_pk PRIMARY KEY
                   USING INDEX TABLESPACE [[2m_tbs]],
    server_Id  NUMBER NOT NULL
                   CONSTRAINT rhn_serverhistory_sid_fk
                       REFERENCES rhnServer (id),
    summary    VARCHAR2(256) NOT NULL,
    details    VARCHAR2(4000),
    created    DATE
                   DEFAULT (sysdate) NOT NULL,
    modified   DATE
                   DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_server_hist_server_id_idx
    ON rhnServerHistory (server_id)
    TABLESPACE [[4m_tbs]];

