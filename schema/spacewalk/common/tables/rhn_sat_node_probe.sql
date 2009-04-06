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


CREATE TABLE rhn_sat_node_probe
(
    probe_id     NUMBER NOT NULL 
                     CONSTRAINT rhn_sndpb_probe_id_pk PRIMARY KEY 
                     USING INDEX TABLESPACE [[2m_tbs]], 
    probe_type   VARCHAR2(12) 
                     DEFAULT ('satnode') NOT NULL 
                     CONSTRAINT rhn_sndpb_probe_type_ck
                         CHECK (probe_type = 'satnode'), 
    sat_node_id  NUMBER NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_sat_node_probe IS 'sndpb  satellite node probe definitions';

CREATE INDEX rhn_sndpb_sat_node_id_idx
    ON rhn_sat_node_probe (sat_node_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_sndpb_pid_ptype_idx
    ON rhn_sat_node_probe (probe_id, probe_type)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhn_sat_node_probe
    ADD CONSTRAINT rhn_sndpb_pr_recid_pr_typ_fk FOREIGN KEY (probe_id, probe_type)
    REFERENCES rhn_probe (recid, probe_type) 
        ON DELETE CASCADE;

ALTER TABLE rhn_sat_node_probe
    ADD CONSTRAINT rhn_sndpb_satnd_sat_nd_id_fk FOREIGN KEY (sat_node_id)
    REFERENCES rhn_sat_node (recid) 
        ON DELETE CASCADE;

