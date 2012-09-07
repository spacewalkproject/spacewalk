--
-- Copyright (c) 2010--2012 Red Hat, Inc.
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


CREATE TABLE rhnPackageChangeLogRec
(
    id          NUMBER NOT NULL
                    CONSTRAINT rhn_pkg_clr_id_pk PRIMARY KEY
                    USING INDEX TABLESPACE [[64k_tbs]],
    package_id  NUMBER NOT NULL
                    CONSTRAINT rhn_pkg_clr_pid_fk
                        REFERENCES rhnPackage (id)
                        ON DELETE CASCADE,
    changelog_data_id  NUMBER NOT NULL
                    CONSTRAINT rhn_pkg_clr_cld_fk
                        REFERENCES rhnPackageChangeLogData (id),
    created     timestamp with local time zone
                    DEFAULT (current_timestamp) NOT NULL,
    modified    timestamp with local time zone
                    DEFAULT (current_timestamp) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_pkg_clr_pid_cld_uq
    ON rhnPackageChangeLogRec (package_id, changelog_data_id)
    NOLOGGING
    TABLESPACE [[32m_tbs]];

CREATE INDEX rhn_pkg_clr_cld_uq
    ON rhnPackageChangeLogRec (changelog_data_id)
    NOLOGGING
    TABLESPACE [[32m_tbs]];

CREATE SEQUENCE rhn_pkg_cl_id_seq;

