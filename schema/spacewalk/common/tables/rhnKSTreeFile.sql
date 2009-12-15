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


CREATE TABLE rhnKSTreeFile
(
    kstree_id          NUMBER NOT NULL
                           CONSTRAINT rhn_kstreefile_kid_fk
                               REFERENCES rhnKickstartableTree (id)
                               ON DELETE CASCADE,
    relative_filename  VARCHAR2(256) NOT NULL,
    checksum_id        NUMBER NOT NULL
                          CONSTRAINT rhn_kstreefile_chsum_fk
                           REFERENCES rhnChecksum (id),
    file_size          NUMBER NOT NULL,
    last_modified      DATE
                           DEFAULT (sysdate) NOT NULL,
    created            DATE
                           DEFAULT (sysdate) NOT NULL,
    modified           DATE
                           DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_kstreefile_kid_rfn_uq
    ON rhnKSTreeFile (kstree_id, relative_filename)
    TABLESPACE [[8m_tbs]];

