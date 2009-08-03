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


CREATE TABLE rhnKSTreeType
(
    id        NUMBER NOT NULL
                  CONSTRAINT rhn_kstreetype_id_pk PRIMARY KEY
                  USING INDEX TABLESPACE [[64k_tbs]],
    label     VARCHAR2(32) NOT NULL,
    name      VARCHAR2(64) NOT NULL,
    created   DATE
                  DEFAULT (sysdate) NOT NULL,
    modified  DATE
                  DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_kstreetype_label_uq
    ON rhnKSTreeType (label)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE rhn_kstree_type_seq;

