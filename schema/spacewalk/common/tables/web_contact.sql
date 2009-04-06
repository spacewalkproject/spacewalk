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


CREATE TABLE web_contact
(
    id                 NUMBER 
                           CONSTRAINT web_contact_pk PRIMARY KEY 
                           USING INDEX TABLESPACE [[web_index_tablespace_2]], 
    org_id             NUMBER NOT NULL 
                           CONSTRAINT web_contact_org_fk
                               REFERENCES web_customer (id), 
    login              VARCHAR2(64) NOT NULL, 
    login_uc           VARCHAR2(64) NOT NULL 
                           CONSTRAINT web_contact_login_uc_unq UNIQUE 
                           USING INDEX TABLESPACE [[web_index_tablespace_2]], 
    password           VARCHAR2(38) NOT NULL, 
    old_password       VARCHAR2(38), 
    created            DATE 
                           DEFAULT (sysdate) NOT NULL, 
    modified           DATE 
                           DEFAULT (sysdate) NOT NULL, 
    oracle_contact_id  NUMBER 
                           CONSTRAINT web_contact_ocid_unq UNIQUE 
                           USING INDEX TABLESPACE [[web_index_tablespace_2]], 
    ignore_flag        CHAR(1) 
                           DEFAULT ('N') NOT NULL 
                           CONSTRAINT web_contact_ignore_ck
                               CHECK (ignore_flag in ( 'N' , 'Y' ))
)
TABLESPACE [[web_tablespace_2]]
ENABLE ROW MOVEMENT
;

CREATE INDEX web_contact_oid_id
    ON web_contact (org_id, id)
    TABLESPACE [[web_index_tablespace_2]];

CREATE INDEX web_contact_id_oid_cust_luc
    ON web_contact (id, oracle_contact_id, org_id, login_uc)
    TABLESPACE [[web_index_tablespace_2]];

CREATE SEQUENCE web_contact_id_seq;

