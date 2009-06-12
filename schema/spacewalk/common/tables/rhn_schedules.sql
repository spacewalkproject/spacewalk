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


CREATE TABLE rhn_schedules
(
    recid             NUMBER NOT NULL
                          CONSTRAINT rhn_sched_recid_pk PRIMARY KEY
                          USING INDEX TABLESPACE [[2m_tbs]]
                          CONSTRAINT rhn_sched_recid_ck
                              CHECK (recid > 0),
    schedule_type_id  NUMBER NOT NULL,
    description       VARCHAR2(40)
                          DEFAULT ('unknown') NOT NULL,
    last_update_user  VARCHAR2(40),
    last_update_date  DATE,
    customer_id       NUMBER
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_schedules IS 'sched  schedule definitions';

CREATE INDEX rhn_sched_schedule_type_id_idx
    ON rhn_schedules (schedule_type_id)
    TABLESPACE [[2m_tbs]];

CREATE UNIQUE INDEX rhn_cust_cust_id_desc_uq
    ON rhn_schedules (customer_id, description)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_schedules_recid_seq;

ALTER TABLE rhn_schedules
    ADD CONSTRAINT rhn_sched_cstmr_cust_id_fk FOREIGN KEY (customer_id)
    REFERENCES web_customer (id);

ALTER TABLE rhn_schedules
    ADD CONSTRAINT rhn_sched_schtp_sched_ty_fk FOREIGN KEY (schedule_type_id)
    REFERENCES rhn_schedule_types (recid);

