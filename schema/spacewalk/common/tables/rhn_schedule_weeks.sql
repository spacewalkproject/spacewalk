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


CREATE TABLE rhn_schedule_weeks
(
    recid                  NUMBER NOT NULL 
                               CONSTRAINT rhn_schwk_recid_pk PRIMARY KEY 
                               USING INDEX TABLESPACE [[2m_tbs]] 
                               CONSTRAINT rhn_schwk_recid_ck
                                   CHECK (recid > 0), 
    schedule_id            NUMBER NOT NULL, 
    component_schedule_id  NUMBER, 
    ord                    NUMBER, 
    last_update_user       VARCHAR2(40), 
    last_update_date       DATE
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_schedule_weeks IS 'schwk  individual week records for schedules';

CREATE INDEX rhn_schwk_schedule_id_idx
    ON rhn_schedule_weeks (schedule_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_schwk_comp_sched_id_idx
    ON rhn_schedule_weeks (component_schedule_id)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_schedule_weeks_recid_seq;

ALTER TABLE rhn_schedule_weeks
    ADD CONSTRAINT rhn_schwk_sched_comp_sched_fk FOREIGN KEY (component_schedule_id)
    REFERENCES rhn_schedules (recid);

ALTER TABLE rhn_schedule_weeks
    ADD CONSTRAINT rhn_schwk_sched_sched_id_fk FOREIGN KEY (schedule_id)
    REFERENCES rhn_schedules (recid) 
        ON DELETE CASCADE;

