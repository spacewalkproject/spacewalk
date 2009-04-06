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


CREATE TABLE rhnActionPackageRemovalFailure
(
    server_id      NUMBER NOT NULL 
                       CONSTRAINT rhn_apr_failure_sid_fk
                           REFERENCES rhnServer (id), 
    action_id      NUMBER NOT NULL 
                       CONSTRAINT rhn_apr_failure_aid_fk
                           REFERENCES rhnAction (id) 
                           ON DELETE CASCADE, 
    name_id        NUMBER NOT NULL 
                       CONSTRAINT rhn_apr_failure_nid_fk
                           REFERENCES rhnPackageName (id), 
    evr_id         NUMBER NOT NULL 
                       CONSTRAINT rhn_apr_failure_eid_fk
                           REFERENCES rhnPackageEVR (id), 
    capability_id  NUMBER NOT NULL 
                       CONSTRAINT rhn_apr_failure_capid_fk
                           REFERENCES rhnPackageCapability (id), 
    flags          NUMBER NOT NULL, 
    suggested      NUMBER 
                       CONSTRAINT rhn_apr_failure_suggested_fk
                           REFERENCES rhnPackageName (id), 
    sense          NUMBER NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_apr_failure_aid_sid_idx
    ON rhnActionPackageRemovalFailure (action_id, server_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_apr_failure_sid_idx
    ON rhnActionPackageRemovalFailure (server_id)
    TABLESPACE [[4m_tbs]];

