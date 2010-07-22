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


CREATE TABLE rhn_command_target
(
    recid        NUMBER NOT NULL,
    target_type  VARCHAR2(10) NOT NULL
                     CONSTRAINT cmdtg_target_type_ck
                         CHECK (target_type in ( 'cluster' , 'node' )),
    customer_id  NUMBER(12) NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_command_target IS 'cmdtg  command target (cluster or node)';

CREATE UNIQUE INDEX rhn_cmdtg_recid_pk
    ON rhn_command_target (recid, target_type)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_cmdtg_cid_idx
    ON rhn_command_target (customer_id)
    TABLESPACE [[4m_tbs]];

CREATE SEQUENCE rhn_command_target_recid_seq;

ALTER TABLE rhn_command_target
    ADD CONSTRAINT rhn_cmdtg_recid_target_type_pk PRIMARY KEY (recid, target_type);

ALTER TABLE rhn_command_target
    ADD CONSTRAINT rhn_cmdtg_cstmr_customer_id_fk FOREIGN KEY (customer_id)
    REFERENCES web_customer (id);

