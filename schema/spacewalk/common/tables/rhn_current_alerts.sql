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


CREATE TABLE rhn_current_alerts
(
    recid               NUMBER(12) NOT NULL
                            CONSTRAINT rhn_alrts_recid_pk PRIMARY KEY
                            USING INDEX TABLESPACE [[128m_tbs]],
    date_submitted      DATE,
    last_server_change  DATE,
    date_completed      DATE
                            DEFAULT (to_date('31-12-9999', 'dd-mm-yyyy')),
    original_server     NUMBER(12),
    current_server      NUMBER(12),
    tel_args            VARCHAR2(2200),
    message             VARCHAR2(2000),
    ticket_id           VARCHAR2(80),
    destination_name    VARCHAR2(50),
    escalation_level    NUMBER(2)
                            DEFAULT (0),
    host_probe_id       NUMBER(12),
    host_state          VARCHAR2(255),
    service_probe_id    NUMBER(12),
    service_state       VARCHAR2(255),
    customer_id         NUMBER(12) NOT NULL,
    netsaint_id         NUMBER(12),
    probe_type          VARCHAR2(20)
                            DEFAULT ('none'),
    in_progress         CHAR(1)
                            DEFAULT (1) NOT NULL,
    last_update_date    DATE,
    event_timestamp     DATE
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_current_alerts IS 'alrts  current alert records';

CREATE INDEX rhn_alrts_service_probe_id_idx
    ON rhn_current_alerts (service_probe_id)
    TABLESPACE [[128m_tbs]];

CREATE INDEX rhn_alrts_current_server_idx
    ON rhn_current_alerts (current_server)
    TABLESPACE [[128m_tbs]];

CREATE INDEX rhn_alrts_in_progress_idx
    ON rhn_current_alerts (in_progress)
    TABLESPACE [[128m_tbs]];

CREATE INDEX rhn_alrts_ticket_id_idx
    ON rhn_current_alerts (ticket_id)
    TABLESPACE [[128m_tbs]];

CREATE INDEX rhn_alrts_customer_id_idx
    ON rhn_current_alerts (customer_id)
    TABLESPACE [[128m_tbs]];

CREATE INDEX rhn_alrts_netsaint_id_idx
    ON rhn_current_alerts (netsaint_id)
    TABLESPACE [[128m_tbs]];

CREATE INDEX rhn_alrts_probe_type_idx
    ON rhn_current_alerts (probe_type)
    TABLESPACE [[128m_tbs]];

CREATE INDEX rhn_alrts_original_server_idx
    ON rhn_current_alerts (original_server)
    TABLESPACE [[128m_tbs]];

CREATE INDEX rhn_alrts_host_probe_id_idx
    ON rhn_current_alerts (host_probe_id)
    TABLESPACE [[128m_tbs]];

CREATE SEQUENCE rhn_current_alerts_recid_seq;

