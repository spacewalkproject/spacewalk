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


CREATE TABLE rhnFileList
(
    id        NUMBER NOT NULL 
                  CONSTRAINT rhn_filelist_id_pk PRIMARY KEY 
                  USING INDEX TABLESPACE [[4m_tbs]], 
    label     VARCHAR2(128) NOT NULL, 
    org_id    NUMBER NOT NULL 
                  CONSTRAINT rhn_filelist_oid_fk
                      REFERENCES web_customer (id), 
    created   DATE 
                  DEFAULT (sysdate) NOT NULL, 
    modified  DATE 
                  DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_filelist_oid_l_uq
    ON rhnFileList (org_id, label)
    TABLESPACE [[8m_tbs]];

CREATE SEQUENCE rhn_filelist_id_seq;

