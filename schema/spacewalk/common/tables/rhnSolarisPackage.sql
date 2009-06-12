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


CREATE TABLE rhnSolarisPackage
(
    package_id  NUMBER
                    CONSTRAINT rhn_solaris_pkg_pid_pk PRIMARY KEY
                    CONSTRAINT rhn_solaris_pkg_pid_fk
                        REFERENCES rhnPackage (id)
                        ON DELETE CASCADE,
    category    VARCHAR2(2048) NOT NULL,
    pkginfo     VARCHAR2(4000),
    pkgmap      BLOB,
    intonly     CHAR(1)
                    DEFAULT ('N')
                    CONSTRAINT rhn_solaris_pkg_io_ck
                        CHECK (intonly in ( 'Y' , 'N' ))
)
TABLESPACE [[8m_data_tbs]]
ENABLE ROW MOVEMENT
;

