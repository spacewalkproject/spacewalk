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


CREATE TABLE rhnFile
(
    id         NUMBER NOT NULL
                   CONSTRAINT rhn_file_id_pk PRIMARY KEY
                   USING INDEX TABLESPACE [[64k_tbs]],
    org_id     NUMBER
                   CONSTRAINT rhn_file_oid_fk
                       REFERENCES web_customer (id)
                       ON DELETE CASCADE,
    file_size  NUMBER NOT NULL,
    checksum_id NUMBER NOT NULL
                   CONSTRAINT rhn_file_chsum_fk
                       REFERENCES rhnChecksum (id),
    path       VARCHAR2(1000) NOT NULL,
    created    DATE
                   DEFAULT (sysdate) NOT NULL,
    modified   DATE
                   DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_file_path_uq
    ON rhnFile (path)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_file_id_seq;

