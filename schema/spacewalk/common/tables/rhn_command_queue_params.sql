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


CREATE TABLE rhn_command_queue_params
(
    instance_id  NUMBER NOT NULL, 
    ord          NUMBER NOT NULL, 
    value        VARCHAR2(1024)
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_command_queue_params IS 'cqprm   command queue parameter definitions';

CREATE UNIQUE INDEX rhn_cqprm_instance_id_ord_pk
    ON rhn_command_queue_params (instance_id, ord)
    TABLESPACE [[4m_tbs]];

ALTER TABLE rhn_command_queue_params
    ADD CONSTRAINT rhn_cqprm_instance_id_ord_pk PRIMARY KEY (instance_id, ord);

ALTER TABLE rhn_command_queue_params
    ADD CONSTRAINT rhn_cqprm_cqins_instance_id_fk FOREIGN KEY (instance_id)
    REFERENCES rhn_command_queue_instances (recid) 
        ON DELETE CASCADE;

