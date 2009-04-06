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


CREATE TABLE rhn_redirects
(
    recid                NUMBER NOT NULL 
                             CONSTRAINT rhn_rdrct_recid_pk PRIMARY KEY 
                             USING INDEX TABLESPACE [[8m_tbs]], 
    customer_id          NUMBER, 
    contact_id           NUMBER, 
    redirect_type        VARCHAR2(20) NOT NULL, 
    description          VARCHAR2(25), 
    reason               VARCHAR2(2000), 
    expiration           DATE NOT NULL, 
    last_update_user     VARCHAR2(40), 
    last_update_date     DATE, 
    start_date           DATE NOT NULL, 
    recurring            NUMBER 
                             DEFAULT (0) NOT NULL 
                             CONSTRAINT RHN_RDRCT_RECUR_VALID
                                 CHECK (recurring in ( 0 , 1 )), 
    recurring_frequency  NUMBER 
                             DEFAULT (2) 
                             CONSTRAINT RHN_RDRCT_RECUR_FREQ_VALID
                                 CHECK (recurring_frequency in ( 2 , 3 , 6 )), 
    recurring_duration   NUMBER 
                             DEFAULT (0), 
    recurring_dur_type   NUMBER 
                             DEFAULT (12) 
                             CONSTRAINT rhn_rdrct_rec_dtype_valid
                                 CHECK (recurring_dur_type in ( 12 , 11 , 5 , 3 , 1 ))
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_redirects IS 'rdrct  redirect definitions';

CREATE INDEX rhn_rdrct_customer_id_idx
    ON rhn_redirects (customer_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_rdrct_redirect_type_idx
    ON rhn_redirects (redirect_type)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_rdrct_cid_idx
    ON rhn_redirects (contact_id)
    TABLESPACE [[4m_tbs]];

CREATE SEQUENCE rhn_redirects_recid_seq;

ALTER TABLE rhn_redirects
    ADD 
    CONSTRAINT rhn_rdrct_start_lte_expir
        CHECK (start_date <= expiration);

ALTER TABLE rhn_redirects
    ADD CONSTRAINT rhn_rdrct_cntct_contact_id_fk FOREIGN KEY (contact_id)
    REFERENCES web_contact (id);

ALTER TABLE rhn_redirects
    ADD CONSTRAINT rhn_rdrct_cstmr_customer_id_fk FOREIGN KEY (customer_id)
    REFERENCES web_customer (id);

ALTER TABLE rhn_redirects
    ADD CONSTRAINT rhn_rdrct_rdrtp_redir_type_fk FOREIGN KEY (redirect_type)
    REFERENCES rhn_redirect_types (name);

