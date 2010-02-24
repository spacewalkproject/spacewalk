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


CREATE TABLE rhnPackageRepodata
(
    package_id  NUMBER NOT NULL
                    CONSTRAINT rhn_pkey_rd_pid_fk
                        REFERENCES rhnPackage (id)
                        ON DELETE CASCADE,
    primary     BLOB,
    filelist    BLOB, 
    other       BLOB,
    created     DATE
                    DEFAULT (sysdate) NOT NULL,
    modified    DATE
                    DEFAULT (sysdate) NOT NULL
)
;

CREATE UNIQUE INDEX rhn_pkey_rd_pk_uq
    ON rhnPackageKeyAssociation (package_id, key_id)
    TABLESPACE [[64k_tbs]];

