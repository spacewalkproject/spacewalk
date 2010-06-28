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


CREATE TABLE rhn_ll_netsaint
(
    netsaint_id  NUMBER(12) NOT NULL,
    city         VARCHAR2(255)
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_ll_netsaint IS 'llnet  scout records';

CREATE INDEX rhn_ll_ntsnts_nsid_idx
    ON rhn_ll_netsaint (netsaint_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

ALTER TABLE rhn_ll_netsaint
    ADD CONSTRAINT rhn_llnts_sat_cluster_idfk FOREIGN KEY (netsaint_id)
    REFERENCES rhn_sat_cluster (recid);

