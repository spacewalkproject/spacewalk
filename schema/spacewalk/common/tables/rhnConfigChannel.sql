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


CREATE TABLE rhnConfigChannel
(
    id                NUMBER NOT NULL 
                          CONSTRAINT rhn_confchan_id_pk PRIMARY KEY 
                          USING INDEX TABLESPACE [[2m_tbs]], 
    org_id            NUMBER NOT NULL 
                          CONSTRAINT rhn_confchan_oid_fk
                              REFERENCES web_customer (id), 
    confchan_type_id  NUMBER NOT NULL 
                          CONSTRAINT rhn_confchan_ctid_fk
                              REFERENCES rhnConfigChannelType (id), 
    name              VARCHAR2(128) NOT NULL, 
    label             VARCHAR2(64) NOT NULL, 
    description       VARCHAR2(1024) NOT NULL, 
    created           DATE 
                          DEFAULT (sysdate) NOT NULL, 
    modified          DATE 
                          DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_confchan_oid_label_type_uq
    ON rhnConfigChannel (org_id, label, confchan_type_id)
    TABLESPACE [[4m_tbs]];

CREATE SEQUENCE rhn_confchan_id_seq;

