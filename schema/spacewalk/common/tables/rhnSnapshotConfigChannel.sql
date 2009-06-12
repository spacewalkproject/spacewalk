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


CREATE TABLE rhnSnapshotConfigChannel
(
    snapshot_id        NUMBER NOT NULL
                           CONSTRAINT rhn_snapshotcc_sid_fk
                               REFERENCES rhnSnapshot (id)
                               ON DELETE CASCADE,
    config_channel_id  NUMBER NOT NULL
                           CONSTRAINT rhn_snapshotcc_ccid_fk
                               REFERENCES rhnConfigChannel (id),
    created            DATE
                           DEFAULT (sysdate) NOT NULL,
    modified           DATE
                           DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_snapshotcc_sid_ccid_uq
    ON rhnSnapshotConfigChannel (snapshot_id, config_channel_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_snpsht_cc_ccid_sid_idx
    ON rhnSnapshotConfigChannel (config_channel_id, snapshot_id)
    TABLESPACE [[4m_tbs]];

