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


CREATE TABLE rhnErrataFileChannelTmp
(
    channel_id      NUMBER NOT NULL
                        CONSTRAINT rhn_efilectmp_cid_fk
                            REFERENCES rhnChannel (id)
                            ON DELETE CASCADE,
    errata_file_id  NUMBER NOT NULL
                        CONSTRAINT rhn_efilectmp_eid_fk
                            REFERENCES rhnErrataFileTmp (id)
                            ON DELETE CASCADE,
    created         DATE
                        DEFAULT (sysdate) NOT NULL,
    modified        DATE
                        DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_efilectmp_efid_cid_idx
    ON rhnErrataFileChannelTmp (errata_file_id, channel_id)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_efilectmp_cid_efid_idx
    ON rhnErrataFileChannelTmp (channel_id, errata_file_id)
    TABLESPACE [[64k_tbs]];

ALTER TABLE rhnErrataFileChannelTmp
    ADD CONSTRAINT rhn_efilectmp_efid_cid_uq UNIQUE (errata_file_id, channel_id);

