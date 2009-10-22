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


CREATE TABLE rhnServerPackage
(
    server_id        NUMBER NOT NULL
                         REFERENCES rhnServer (id)
                             ON DELETE CASCADE,
    name_id          NUMBER NOT NULL
                         REFERENCES rhnPackageName (id),
    evr_id           NUMBER NOT NULL
                         REFERENCES rhnPackageEVR (id),
    package_arch_id  NUMBER
                         REFERENCES rhnPackageArch (id),
    created          DATE
                         DEFAULT (sysdate) NOT NULL,
    installtime      DATE
)
TABLESPACE [[server_package_tablespace]]
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_sp_snep_idx
    ON rhnServerPackage (server_id, name_id, evr_id, package_arch_id)
    TABLESPACE [[128m_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_server_package_id_seq;

