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


CREATE TABLE rhnTag
(
    id        NUMBER NOT NULL 
                  CONSTRAINT rhn_tag_id_pk PRIMARY KEY, 
    name_id   NUMBER NOT NULL 
                  CONSTRAINT rhn_tag_nid_fk
                      REFERENCES rhnTagName (id), 
    org_id    NUMBER NOT NULL 
                  CONSTRAINT rhn_tag_oid_fk
                      REFERENCES web_customer (id) 
                      ON DELETE CASCADE, 
    created   DATE 
                  DEFAULT (sysdate) NOT NULL, 
    modified  DATE 
                  DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_tag_oid_nid_uq
    ON rhnTag (org_id, name_id);

CREATE SEQUENCE rhn_tag_id_seq;

