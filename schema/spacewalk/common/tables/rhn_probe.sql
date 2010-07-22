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


CREATE TABLE rhn_probe
(
    recid                          NUMBER NOT NULL
                                       CONSTRAINT rhn_probe_recid_pk PRIMARY KEY
                                       USING INDEX TABLESPACE [[8m_tbs]],
    probe_type                     VARCHAR2(15) NOT NULL,
    description                    VARCHAR2(255) NOT NULL,
    customer_id                    NUMBER(12) NOT NULL,
    command_id                     NUMBER(16) NOT NULL,
    contact_group_id               NUMBER(12),
    notify_critical                CHAR(1),
    notify_warning                 CHAR(1),
    notify_unknown                 CHAR(1),
    notify_recovery                CHAR(1),
    notification_interval_minutes  NUMBER(16) NOT NULL,
    check_interval_minutes         NUMBER(16) NOT NULL,
    retry_interval_minutes         NUMBER(16) NOT NULL,
    max_attempts                   NUMBER(16),
    last_update_user               VARCHAR2(40),
    last_update_date               DATE
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_probe IS 'probe  probe definitions';

CREATE UNIQUE INDEX rhn_probe_recid_probe_type_uq
    ON rhn_probe (recid, probe_type)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_probe_check_command_id_idx
    ON rhn_probe (command_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_probe_customer_id_idx
    ON rhn_probe (customer_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_probe_probe_type_idx
    ON rhn_probe (probe_type)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_probe_contact_grp_idx
    ON rhn_probe (contact_group_id)
    TABLESPACE [[8m_tbs]];

CREATE SEQUENCE rhn_probes_recid_seq;

ALTER TABLE rhn_probe
    ADD CONSTRAINT rhn_probe_recid_probe_type_uq UNIQUE (recid, probe_type);

ALTER TABLE rhn_probe
    ADD CONSTRAINT rhn_probe_cmmnd_command_id_fk FOREIGN KEY (command_id)
    REFERENCES rhn_command (recid);

ALTER TABLE rhn_probe
    ADD CONSTRAINT rhn_probe_cstmr_customer_id_fk FOREIGN KEY (customer_id)
    REFERENCES web_customer (id);

ALTER TABLE rhn_probe
    ADD CONSTRAINT rhn_probe_prbtp_probe_type_fk FOREIGN KEY (probe_type)
    REFERENCES rhn_probe_types (probe_type);

