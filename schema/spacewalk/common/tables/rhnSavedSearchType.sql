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


CREATE TABLE rhnSavedSearchType
(
    id        NUMBER NOT NULL, 
    label     VARCHAR2(8) NOT NULL, 
    created   DATE 
                  DEFAULT (sysdate) NOT NULL, 
    modified  DATE 
                  DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_sstype_id_label_idx
    ON rhnSavedSearchType (id, label)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_sstype_label_id_idx
    ON rhnSavedSearchType (label, id)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE rhn_sstype_id_seq;

ALTER TABLE rhnSavedSearchType
    ADD CONSTRAINT rhn_sstype_id_pk PRIMARY KEY (id);

ALTER TABLE rhnSavedSearchType
    ADD CONSTRAINT rhn_sstype_label_uq UNIQUE (label);

