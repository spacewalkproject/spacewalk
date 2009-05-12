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


CREATE TABLE rhnServerNeededCache
(
    server_id   NUMBER NOT NULL 
                    CONSTRAINT rhn_sncp_sid_fk
                        REFERENCES rhnServer (id) 
                        ON DELETE CASCADE, 
    errata_id   NUMBER 
                    CONSTRAINT rhn_sncp_eid_fk
                        REFERENCES rhnErrata (id) 
                        ON DELETE CASCADE, 
    package_id  NUMBER NOT NULL 
                    CONSTRAINT rhn_sncp_pid_fk
                        REFERENCES rhnPackage (id) 
                        ON DELETE CASCADE
)
ENABLE ROW MOVEMENT
LOGGING
;

CREATE INDEX rhn_snc_pid_idx
    ON rhnServerNeededCache (package_id)
    NOPARALLEL
    TABLESPACE [[128m_tbs]]
    NOLOGGING;

CREATE INDEX rhn_snc_sid_idx
    ON rhnServerNeededCache (server_id)
    NOPARALLEL
    TABLESPACE [[128m_tbs]]
    NOLOGGING;

CREATE INDEX rhn_snc_eid_idx
    ON rhnServerNeededCache (errata_id)
    TABLESPACE [[128m_tbs]]
    NOLOGGING;

CREATE INDEX rhn_snc_speid_idx
    ON rhnServerNeededCache (server_id, package_id, errata_id)
    NOPARALLEL
    TABLESPACE [[128m_tbs]]
    NOLOGGING;
