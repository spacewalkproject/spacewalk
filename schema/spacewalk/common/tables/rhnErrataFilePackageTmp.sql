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


CREATE TABLE rhnErrataFilePackageTmp
(
    package_id      NUMBER NOT NULL
                        CONSTRAINT rhn_efileptmp_pid_fk
                            REFERENCES rhnPackage (id)
                            ON DELETE CASCADE,
    errata_file_id  NUMBER NOT NULL
                        CONSTRAINT rhn_efileptmp_fileid_fk
                            REFERENCES rhnErrataFileTmp (id)
                            ON DELETE CASCADE,
    created         DATE
                        DEFAULT (sysdate) NOT NULL,
    modified        DATE
                        DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_efileptmp_efid_pid_idx
    ON rhnErrataFilePackageTmp (errata_file_id, package_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_efileptmp_pid_idx
    ON rhnErrataFilePackageTmp (package_id)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhnErrataFilePackageTmp
    ADD CONSTRAINT rhn_efileptmp_efid_uq UNIQUE (errata_file_id);

