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


CREATE TABLE rhn_host_probe
(
    probe_id        NUMBER(12) NOT NULL
                        CONSTRAINT rhn_hstpb_probe_id_pk PRIMARY KEY
                        USING INDEX TABLESPACE [[4m_tbs]],
    probe_type      VARCHAR2(12)
                        DEFAULT ('host') NOT NULL
                        CONSTRAINT rhn_hstpb_probe_type_ck
                            CHECK (probe_type = 'host'),
    host_id         NUMBER(12) NOT NULL,
    sat_cluster_id  NUMBER(12) NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_host_probe IS 'hstpb  host probe definitions';

CREATE INDEX rhn_hstpb_host_id_idx
    ON rhn_host_probe (host_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_hstpb_sat_cluster_id_idx
    ON rhn_host_probe (sat_cluster_id)
    TABLESPACE [[4m_tbs]];

CREATE UNIQUE INDEX rhn_hstpb_pbid_ptype_idx
    ON rhn_host_probe (probe_id, probe_type)
    TABLESPACE [[4m_tbs]];

CREATE SEQUENCE rhn_host_probes_recid_seq;

ALTER TABLE rhn_host_probe
    ADD CONSTRAINT rhn_hstpb_host_id_fk FOREIGN KEY (host_id)
    REFERENCES rhnServer (id);

ALTER TABLE rhn_host_probe
    ADD CONSTRAINT rhn_hstpb_probe_probe_id_fk FOREIGN KEY (probe_id, probe_type)
    REFERENCES rhn_probe (recid, probe_type)
        ON DELETE CASCADE;

ALTER TABLE rhn_host_probe
    ADD CONSTRAINT rhn_hstpb_satcl_id_fk FOREIGN KEY (sat_cluster_id)
    REFERENCES rhn_sat_cluster (recid)
        ON DELETE CASCADE;

