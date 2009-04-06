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


CREATE TABLE rhnPackageChangelog
(
    id          NUMBER NOT NULL 
                    CONSTRAINT rhn_pkg_cl_id_pk PRIMARY KEY 
                    USING INDEX TABLESPACE [[64k_tbs]], 
    package_id  NUMBER NOT NULL 
                    CONSTRAINT rhn_pkg_changelog_pid_fk
                        REFERENCES rhnPackage (id) 
                        ON DELETE CASCADE, 
    name        VARCHAR2(128) NOT NULL, 
    text        VARCHAR2(3000) NOT NULL, 
    time        DATE NOT NULL, 
    created     DATE 
                    DEFAULT (sysdate) NOT NULL, 
    modified    DATE 
                    DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_pkg_cl_pid_n_txt_time_uq
    ON rhnPackageChangelog (package_id, name, text, time)
    LOGGING
    TABLESPACE [[32m_tbs]];

CREATE SEQUENCE rhn_pkg_cl_id_seq;

