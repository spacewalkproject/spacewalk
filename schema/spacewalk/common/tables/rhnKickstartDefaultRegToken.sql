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


CREATE TABLE rhnKickstartDefaultRegToken
(
    kickstart_id  NUMBER NOT NULL
                      CONSTRAINT rhn_ksdrt_ksid_fk
                          REFERENCES rhnKSData (id)
                          ON DELETE CASCADE,
    regtoken_id   NUMBER NOT NULL
                      CONSTRAINT rhn_ksdrt_rtid_fk
                          REFERENCES rhnRegToken (id)
                          ON DELETE CASCADE,
    created       DATE
                      DEFAULT (sysdate) NOT NULL,
    modified      DATE
                      DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_ksdrt_ksid_rtid_idx
    ON rhnKickstartDefaultRegToken (kickstart_id, regtoken_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_ksdrt_rtid_idx
    ON rhnKickstartDefaultRegToken (regtoken_id)
    TABLESPACE [[2m_tbs]];

