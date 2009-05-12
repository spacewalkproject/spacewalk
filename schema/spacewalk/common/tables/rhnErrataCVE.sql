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


CREATE TABLE rhnErrataCVE
(
    errata_id  NUMBER NOT NULL 
                   CONSTRAINT rhn_err_cve_eid_fk
                       REFERENCES rhnErrata (id) 
                       ON DELETE CASCADE, 
    cve_id     NUMBER NOT NULL 
                   CONSTRAINT rhn_err_cve_cid_fk
                       REFERENCES rhnCVE (id), 
    created    DATE 
                   DEFAULT (sysdate) NOT NULL, 
    modified   DATE 
                   DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_err_cve_eid_cid_uq
    ON rhnErrataCVE (errata_id, cve_id)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_err_cve_cid_eid_idx
    ON rhnErrataCVE (cve_id, errata_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

