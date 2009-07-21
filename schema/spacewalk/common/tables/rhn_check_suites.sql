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


CREATE TABLE rhn_check_suites
(
    recid             NUMBER(12) NOT NULL
                          CONSTRAINT rhn_cksut_recid_pk PRIMARY KEY
                          USING INDEX TABLESPACE [[2m_tbs]],
    customer_id       NUMBER(12) NOT NULL,
    suite_name        VARCHAR2(40) NOT NULL,
    description       VARCHAR2(255),
    last_update_user  VARCHAR2(40) NOT NULL,
    last_update_date  DATE NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_check_suites IS 'CKSUT  check suites';

CREATE INDEX rhn_cksut_cid_idx
    ON rhn_check_suites (customer_id)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_check_suites_recid_seq;

ALTER TABLE rhn_check_suites
    ADD CONSTRAINT rhn_cksut_cstmr_customer_id_fk FOREIGN KEY (customer_id)
    REFERENCES web_customer (id);

