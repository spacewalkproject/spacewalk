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


CREATE TABLE rhn_check_probe
(
    probe_id        NUMBER NOT NULL
                        CONSTRAINT rhn_chkpb_probe_id_pk PRIMARY KEY
                        USING INDEX TABLESPACE [[4m_tbs]],
    probe_type      VARCHAR2(12)
                        DEFAULT ('check') NOT NULL
                        CONSTRAINT chkpb_probe_type_ck
                            CHECK (probe_type = 'check'),
    host_id         NUMBER NOT NULL,
    sat_cluster_id  NUMBER NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_check_probe IS 'CHKPB  Service check probe definitions (monitoring)';

CREATE INDEX rhn_chkpb_host_id_idx
    ON rhn_check_probe (host_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_chkpb_sat_cluster_id_idx
    ON rhn_check_probe (sat_cluster_id)
    TABLESPACE [[4m_tbs]];

CREATE UNIQUE INDEX rhn_chkpb_pid_ptype_uq_idx
    ON rhn_check_probe (probe_id, probe_type)
    TABLESPACE [[4m_tbs]];

ALTER TABLE rhn_check_probe
    ADD CONSTRAINT rhn_chkpb_host_id_fk FOREIGN KEY (host_id)
    REFERENCES rhnServer (id);

ALTER TABLE rhn_check_probe
    ADD CONSTRAINT rhn_chkpb_recid_probe_typ_fk FOREIGN KEY (probe_id, probe_type)
    REFERENCES rhn_probe (recid, probe_type)
        ON DELETE CASCADE;

ALTER TABLE rhn_check_probe
    ADD CONSTRAINT rhn_chkpb_satcl_sat_cl_id_fk FOREIGN KEY (sat_cluster_id)
    REFERENCES rhn_sat_cluster (recid)
        ON DELETE CASCADE;

