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


CREATE TABLE rhn_sat_cluster
(
    recid                 NUMBER NOT NULL
                              CONSTRAINT rhn_satcl_recid_pk PRIMARY KEY
                              USING INDEX TABLESPACE [[2m_tbs]],
    target_type           VARCHAR2(10)
                              DEFAULT ('cluster') NOT NULL
                              CONSTRAINT rhn_satcl_target_type_ck
                                  CHECK (target_type in ( 'cluster' )),
    customer_id           NUMBER(12) NOT NULL,
    description           VARCHAR2(255) NOT NULL,
    last_update_user      VARCHAR2(40),
    last_update_date      DATE,
    physical_location_id  NUMBER(12) NOT NULL,
    public_key            VARCHAR2(2000),
    vip                   VARCHAR2(15),
    deployed              CHAR(1)
                              DEFAULT ('0') NOT NULL
                              CONSTRAINT rhn_satcl_deployed_ck
                                  CHECK (deployed in ( '0' , '1' )),
    pem_public_key        VARCHAR2(2000),
    pem_public_key_hash   VARCHAR2(20)
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_sat_cluster IS 'satcl  satellite cluster';

CREATE INDEX rhn_satcl_cid_idx
    ON rhn_sat_cluster (customer_id)
    TABLESPACE [[4m_tbs]];

ALTER TABLE rhn_sat_cluster
    ADD CONSTRAINT rhn_satcl_cmdtg_recid_tar_fk FOREIGN KEY (recid, target_type)
    REFERENCES rhn_command_target (recid, target_type)
        ON DELETE CASCADE;

ALTER TABLE rhn_sat_cluster
    ADD CONSTRAINT rhn_satcl_cstmr_customer_id_fk FOREIGN KEY (customer_id)
    REFERENCES web_customer (id);

ALTER TABLE rhn_sat_cluster
    ADD CONSTRAINT rhn_satcl_phslc_phys_loc_fk FOREIGN KEY (physical_location_id)
    REFERENCES rhn_physical_location (recid);

