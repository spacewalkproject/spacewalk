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


CREATE TABLE rhnErrataFileTmp
(
    id         NUMBER NOT NULL,
    errata_id  NUMBER NOT NULL
                   CONSTRAINT rhn_erratafiletmp_errata_fk
                       REFERENCES rhnErrataTmp (id)
                       ON DELETE CASCADE,
    type       NUMBER NOT NULL
                   CONSTRAINT rhn_erratafiletmp_type_fk
                       REFERENCES rhnErrataFileType (id),
    checksum_id NUMBER NOT NULL,
                   CONSTRAINT rhn_erratafiletmp_chsum_fk
                       REFERENCES rhnChecksum (id),
    filename   VARCHAR2(128) NOT NULL,
    created    DATE
                   DEFAULT (sysdate) NOT NULL,
    modified   DATE
                   DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_erratafiletmp_id_idx
    ON rhnErrataFileTmp (id)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_erratafiletmp_eid_file_idx
    ON rhnErrataFileTmp (errata_id, filename)
    TABLESPACE [[64k_tbs]];

ALTER TABLE rhnErrataFileTmp
    ADD CONSTRAINT rhn_erratafiletmp_id_pk PRIMARY KEY (id);

ALTER TABLE rhnErrataFileTmp
    ADD CONSTRAINT rhn_erratafiletmp_eid_file_uq UNIQUE (errata_id, filename);

