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


CREATE TABLE rhnServerProfilePackage
(
    server_profile_id  NUMBER NOT NULL 
                           CONSTRAINT rhn_sprofile_spid_fk
                               REFERENCES rhnServerProfile (id) 
                               ON DELETE CASCADE, 
    name_id            NUMBER NOT NULL 
                           CONSTRAINT rhn_sprofile_nid_fk
                               REFERENCES rhnPackageName (id), 
    evr_id             NUMBER NOT NULL 
                           CONSTRAINT rhn_sprofile_evrid_fk
                               REFERENCES rhnPackageEvr (id), 
    package_arch_id    NUMBER 
                           CONSTRAINT rhn_sprofile_package_fk
                               REFERENCES rhnPackageArch (id)
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_sprof_sp_sne_idx
    ON rhnServerProfilePackage (server_profile_id, name_id, evr_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

