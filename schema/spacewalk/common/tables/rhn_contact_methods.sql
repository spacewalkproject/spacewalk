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


CREATE TABLE rhn_contact_methods
(
    recid                      NUMBER NOT NULL
                                   CONSTRAINT rhn_cmeth_recid_pk PRIMARY KEY
                                   USING INDEX TABLESPACE [[2m_tbs]]
                                   CONSTRAINT rhn_cmeth_recid_notzero
                                       CHECK (recid > 0),
    method_name                VARCHAR2(20),
    contact_id                 NUMBER(12) NOT NULL,
    schedule_id                NUMBER(12),
    method_type_id             NUMBER(12) NOT NULL,
    pager_type_id              NUMBER(12),
    pager_pin                  VARCHAR2(20),
    pager_email                VARCHAR2(50),
    pager_max_message_length   NUMBER(6)
                                   CONSTRAINT rhn_cmeth_pgr_length_limit
                                       CHECK (pager_max_message_length between 10 and 1920),
    pager_split_long_messages  CHAR(1),
    email_address              VARCHAR2(50),
    email_reply_to             VARCHAR2(50),
    last_update_user           VARCHAR2(40),
    last_update_date           DATE,
    snmp_host                  VARCHAR2(255),
    snmp_port                  NUMBER(5),
    notification_format_id     NUMBER(12)
                                   DEFAULT (4) NOT NULL,
    sender_sat_cluster_id      NUMBER(12)
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_contact_methods IS 'cmeth  contact method definitions';

CREATE INDEX rhn_cmeth_sndr_scid_idx
    ON rhn_contact_methods (sender_sat_cluster_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_cmeth_contact_id_idx
    ON rhn_contact_methods (contact_id)
    TABLESPACE [[2m_tbs]];

CREATE UNIQUE INDEX rhn_cmeth_id_name_uq
    ON rhn_contact_methods (contact_id, method_name)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_cmeth_method_type_id_idx
    ON rhn_contact_methods (method_type_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_cmeth_schedule_id_idx
    ON rhn_contact_methods (schedule_id)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_contact_methods_recid_seq;

ALTER TABLE rhn_contact_methods
    ADD CONSTRAINT rhn_cmeth_contact_id_fk FOREIGN KEY (contact_id)
    REFERENCES web_contact (id);

ALTER TABLE rhn_contact_methods
    ADD CONSTRAINT rhn_cmeth_method_type_id_fk FOREIGN KEY (method_type_id)
    REFERENCES rhn_method_types (recid);

ALTER TABLE rhn_contact_methods
    ADD CONSTRAINT rhn_cmeth_pager_type_id_fk FOREIGN KEY (pager_type_id)
    REFERENCES rhn_pager_types (recid);

ALTER TABLE rhn_contact_methods
    ADD CONSTRAINT rhn_cmeth_sender_sat_clus_fk FOREIGN KEY (sender_sat_cluster_id)
    REFERENCES rhn_sat_cluster (recid);

ALTER TABLE rhn_contact_methods
    ADD CONSTRAINT rhn_cmeth_schedule_id_fk FOREIGN KEY (schedule_id)
    REFERENCES rhn_schedules (recid);

ALTER TABLE rhn_contact_methods
    ADD CONSTRAINT rhn_cmeth_ntfmt_id_fk FOREIGN KEY (notification_format_id)
    REFERENCES rhn_notification_formats (recid);

