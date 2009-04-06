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


CREATE TABLE rhnKickstartSessionHistory
(
    id                    NUMBER NOT NULL 
                              CONSTRAINT rhn_ks_sessionhist_id_pk PRIMARY KEY 
                              USING INDEX TABLESPACE [[8m_tbs]], 
    kickstart_session_id  NUMBER NOT NULL 
                              CONSTRAINT rhn_ks_sessionhist_ksid_fk
                                  REFERENCES rhnKickstartSession (id) 
                                  ON DELETE CASCADE, 
    action_id             NUMBER 
                              CONSTRAINT rhn_ks_sessionhist_aid_fk
                                  REFERENCES rhnAction (id) 
                                  ON DELETE SET NULL, 
    state_id              NUMBER NOT NULL 
                              CONSTRAINT rhn_ks_sessionhist_stat_fk
                                  REFERENCES rhnKickstartSessionState (id), 
    time                  DATE 
                              DEFAULT (sysdate) NOT NULL, 
    message               VARCHAR2(4000), 
    created               DATE 
                              DEFAULT (sysdate) NOT NULL, 
    modified              DATE 
                              DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_ks_sessionhist_ksid_idx
    ON rhnKickstartSessionHistory (kickstart_session_id)
    TABLESPACE [[8m_tbs]];

CREATE SEQUENCE rhn_ks_sessionhist_id_seq;

