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


CREATE TABLE rhn_sat_cluster_probe
(
    probe_id        NUMBER NOT NULL
                        CONSTRAINT rhn_sclpb_probe_id_pk PRIMARY KEY
                        USING INDEX TABLESPACE [[2m_tbs]],
    probe_type      VARCHAR2(12)
                        DEFAULT ('satcluster') NOT NULL
                        CONSTRAINT rhn_sclpb_probe_type_ck
                            CHECK (probe_type = 'satcluster'),
    sat_cluster_id  NUMBER NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_sat_cluster_probe IS 'sclpb  satellite cluster probe definitions';

CREATE INDEX rhn_sclpb_sat_cluster_id_idx
    ON rhn_sat_cluster_probe (sat_cluster_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_sclpb_pid_ptype_idx
    ON rhn_sat_cluster_probe (probe_id, probe_type)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhn_sat_cluster_probe
    ADD CONSTRAINT rhn_sclpb_prb_recid_prb_typ_fk FOREIGN KEY (probe_id, probe_type)
    REFERENCES rhn_probe (recid, probe_type)
        ON DELETE CASCADE;

ALTER TABLE rhn_sat_cluster_probe
    ADD CONSTRAINT rhn_sclpb_satcl_sat_cl_id_fk FOREIGN KEY (sat_cluster_id)
    REFERENCES rhn_sat_cluster (recid)
        ON DELETE CASCADE;

