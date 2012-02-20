--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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


CREATE TABLE rhn_sat_node
(
    recid                  NUMBER(12) NOT NULL
                               CONSTRAINT rhn_satnd_recid_pk PRIMARY KEY
                               USING INDEX TABLESPACE [[2m_tbs]],
    server_id              NUMBER
                               CONSTRAINT rhn_satnd_sid_fk
                                   REFERENCES rhnServer (id),
    target_type            VARCHAR2(10)
                               DEFAULT ('node') NOT NULL
                               CONSTRAINT rhn_satnd_target_type_ck
                                   CHECK (target_type in ('node')),
    last_update_user       VARCHAR2(40),
    last_update_date       DATE,
    mac_address            VARCHAR2(17) NOT NULL,
    max_concurrent_checks  NUMBER(4),
    sat_cluster_id         NUMBER(12) NOT NULL,
    ip                     VARCHAR2(15),
    ip6                    VARCHAR2(45),
    sched_log_level        NUMBER(4)
                               DEFAULT (0) NOT NULL,
    sput_log_level         NUMBER(4)
                               DEFAULT (0) NOT NULL,
    dq_log_level           NUMBER(4)
                               DEFAULT (0) NOT NULL,
    scout_shared_key       VARCHAR2(64) NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_sat_node IS 'satnd  satellite node';

CREATE INDEX rhn_sat_node_scid_idx
    ON rhn_sat_node (sat_cluster_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE UNIQUE INDEX rhn_sat_node_sid_idx
    ON rhn_sat_node (server_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

ALTER TABLE rhn_sat_node
    ADD CONSTRAINT rhn_satnd_cmdtg_rid_tar_ty_fk FOREIGN KEY (recid, target_type)
    REFERENCES rhn_command_target (recid, target_type)
        ON DELETE CASCADE;

ALTER TABLE rhn_sat_node
    ADD CONSTRAINT rhn_satnd_satcl_sat_cl_id_fk FOREIGN KEY (sat_cluster_id)
    REFERENCES rhn_sat_cluster (recid)
        ON DELETE CASCADE;

