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


CREATE TABLE rhnCustomDataKey
(
    id                NUMBER NOT NULL 
                          CONSTRAINT rhn_cdatakey_pk PRIMARY KEY, 
    org_id            NUMBER NOT NULL 
                          CONSTRAINT rhn_cdatakey_oid_fk
                              REFERENCES web_customer (id) 
                              ON DELETE CASCADE, 
    label             VARCHAR2(64) NOT NULL, 
    description       VARCHAR2(4000) NOT NULL, 
    created_by        NUMBER 
                          CONSTRAINT rhn_cdatakey_cb_fk
                              REFERENCES web_contact (id) 
                              ON DELETE SET NULL, 
    last_modified_by  NUMBER 
                          CONSTRAINT rhn_cdatakey_lmb_fk
                              REFERENCES web_contact (id) 
                              ON DELETE SET NULL, 
    created           DATE 
                          DEFAULT (sysdate) NOT NULL, 
    modified          DATE 
                          DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_cdatakey_oid_label_id_idx
    ON rhnCustomDataKey (org_id, label, id)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_cdatakey_id_seq;

ALTER TABLE rhnCustomDataKey
    ADD CONSTRAINT rhn_cdatakey_oid_label_uq UNIQUE (org_id, label);

