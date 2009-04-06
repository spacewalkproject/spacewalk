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


CREATE TABLE rhnActionVirtReboot
(
    action_id  NUMBER NOT NULL 
                   CONSTRAINT rhn_avreboot_aid_fk
                       REFERENCES rhnAction (id) 
                       ON DELETE CASCADE, 
    uuid       VARCHAR2(128) NOT NULL, 
    created    DATE 
                   DEFAULT (sysdate) NOT NULL, 
    modified   DATE 
                   DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_avreboot_aid_uq
    ON rhnActionVirtReboot (action_id)
    TABLESPACE [[8m_tbs]];

ALTER TABLE rhnActionVirtReboot
    ADD CONSTRAINT rhn_avreboot_aid_pk PRIMARY KEY (action_id);

