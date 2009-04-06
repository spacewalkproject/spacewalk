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


CREATE TABLE rhnActionType
(
    id                NUMBER NOT NULL 
                          CONSTRAINT rhn_action_type_pk PRIMARY KEY 
                          USING INDEX TABLESPACE [[64k_tbs]], 
    label             VARCHAR2(48) NOT NULL, 
    name              VARCHAR2(100) NOT NULL, 
    trigger_snapshot  CHAR(1) 
                          DEFAULT ('N') NOT NULL 
                          CONSTRAINT rhn_action_type_trigsnap_ck
                              CHECK (trigger_snapshot in ( 'Y' , 'N' )), 
    unlocked_only     CHAR(1) 
                          DEFAULT ('N') NOT NULL 
                          CONSTRAINT rhn_action_type_unlck_ck
                              CHECK (unlocked_only in ( 'Y' , 'N' ))
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_action_type_label_uq
    ON rhnActionType (label)
    TABLESPACE [[64k_tbs]];

CREATE UNIQUE INDEX rhn_action_type_name_uq
    ON rhnActionType (name)
    TABLESPACE [[64k_tbs]];

