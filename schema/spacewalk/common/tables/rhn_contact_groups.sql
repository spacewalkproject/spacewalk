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


CREATE TABLE rhn_contact_groups
(
    recid                   NUMBER NOT NULL
                                CONSTRAINT rhn_cntgp_recid_pk PRIMARY KEY
                                USING INDEX TABLESPACE [[2m_tbs]]
                                CONSTRAINT rhn_cntgp_recid_notzero
                                    CHECK (recid > 0),
    contact_group_name      VARCHAR2(30) NOT NULL,
    customer_id             NUMBER(12) NOT NULL,
    strategy_id             NUMBER(12) NOT NULL,
    ack_wait                NUMBER(4) NOT NULL
                                CONSTRAINT rhn_cntgp_ack_wait_ck
                                    CHECK (ack_wait < 20160),
    rotate_first            CHAR(1) NOT NULL
                                CONSTRAINT rhn_cntgp_rotate_f_ck
                                    CHECK (rotate_first in ( '0' , '1' )),
    last_update_user        VARCHAR2(40) NOT NULL,
    last_update_date        DATE NOT NULL,
    notification_format_id  NUMBER(12)
                                DEFAULT (4) NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_contact_groups IS 'cntgp  contact group definitions';

CREATE INDEX rhn_cntgp_strategy_id_idx
    ON rhn_contact_groups (strategy_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_cntgp_customer_id_idx
    ON rhn_contact_groups (customer_id)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_contact_groups_recid_seq;

ALTER TABLE rhn_contact_groups
    ADD CONSTRAINT rhn_cntgp_cstmr_customer_id_fk FOREIGN KEY (customer_id)
    REFERENCES web_customer (id);

ALTER TABLE rhn_contact_groups
    ADD CONSTRAINT rhn_cntgp_strat_strategy_id_fk FOREIGN KEY (strategy_id)
    REFERENCES rhn_strategies (recid);

ALTER TABLE rhn_contact_groups
    ADD CONSTRAINT rhn_ntfmt_cntgp_id_fk FOREIGN KEY (notification_format_id)
    REFERENCES rhn_notification_formats (recid);

