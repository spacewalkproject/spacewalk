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


CREATE TABLE rhnKickstartPackage
(
    kickstart_id     NUMBER NOT NULL
                         CONSTRAINT rhn_kspackage_ksid_fk
                             REFERENCES rhnKSData (id)
                             ON DELETE CASCADE,
    package_name_id  NUMBER NOT NULL
                         CONSTRAINT rhn_kspackage_pnid_fk
                             REFERENCES rhnPackageName (id),
    position         NUMBER NOT NULL
                        CONSTRAINT rhn_kspackage_pos_uq UNIQUE,
    created          DATE
                         DEFAULT (sysdate) NOT NULL,
    modified         DATE
                         DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_kspackage_id_idx
    ON rhnKickstartPackage (kickstart_id)
    TABLESPACE [[4m_tbs]];

