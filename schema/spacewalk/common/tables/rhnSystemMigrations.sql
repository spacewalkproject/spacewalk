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


CREATE TABLE rhnSystemMigrations
(
    org_id_to    NUMBER NOT NULL 
                     CONSTRAINT rhn_sys_mig_oidto_fk
                         REFERENCES web_customer (id) 
                         ON DELETE SET NULL, 
    org_id_from  NUMBER NOT NULL 
                     CONSTRAINT rhn_sys_mig_oidfrm_fk
                         REFERENCES web_customer (id) 
                         ON DELETE SET NULL, 
    server_id    NUMBER NOT NULL 
                     CONSTRAINT rhn_sys_mig_sid_fk
                         REFERENCES rhnServer (id) 
                         ON DELETE CASCADE, 
    migrated     DATE 
                     DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rsm_org_id_to_idx
    ON rhnSystemMigrations (org_id_to);

CREATE INDEX rsm_org_id_from_idx
    ON rhnSystemMigrations (org_id_from);

