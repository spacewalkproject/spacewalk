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


CREATE TABLE rhn_command_queue_execs
(
    instance_id       NUMBER NOT NULL, 
    netsaint_id       NUMBER NOT NULL, 
    date_accepted     DATE, 
    date_executed     DATE, 
    exit_status       NUMBER, 
    execution_time    NUMBER, 
    stdout            VARCHAR2(4000), 
    stderr            VARCHAR2(4000), 
    last_update_date  DATE, 
    target_type       VARCHAR2(10) NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_command_queue_execs IS 'cqexe  command queue execution records';

CREATE UNIQUE INDEX rhn_cqexe_inst_id_nsaint_pk
    ON rhn_command_queue_execs (instance_id, netsaint_id);

CREATE INDEX rhn_command_queue_netsaint_idx
    ON rhn_command_queue_execs (netsaint_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_cqexe_instance_id_idx
    ON rhn_command_queue_execs (instance_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_cqexe_date_executed_idx
    ON rhn_command_queue_execs (date_executed)
    TABLESPACE [[8m_tbs]];

ALTER TABLE rhn_command_queue_execs
    ADD CONSTRAINT rhn_cqexe_inst_id_nsaint_pk PRIMARY KEY (instance_id, netsaint_id);

ALTER TABLE rhn_command_queue_execs
    ADD CONSTRAINT rhn_cqexe_cqins_inst_id_fk FOREIGN KEY (instance_id)
    REFERENCES rhn_command_queue_instances (recid) 
        ON DELETE CASCADE;

ALTER TABLE rhn_command_queue_execs
    ADD CONSTRAINT rhn_cqexe_satcl_nsaint_id_fk FOREIGN KEY (netsaint_id, target_type)
    REFERENCES rhn_command_target (recid, target_type) 
        ON DELETE CASCADE;

