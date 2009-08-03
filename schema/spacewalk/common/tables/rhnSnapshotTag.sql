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


CREATE TABLE rhnSnapshotTag
(
    snapshot_id  NUMBER NOT NULL
                     CONSTRAINT rhn_st_ssid_fk
                         REFERENCES rhnSnapshot (id)
                         ON DELETE CASCADE,
    tag_id       NUMBER NOT NULL
                     CONSTRAINT rhn_st_tid_fk
                         REFERENCES rhnTag (id),
    server_id    NUMBER
                     CONSTRAINT rhn_st_sid_fk
                         REFERENCES rhnServer (id),
    created      DATE
                     DEFAULT (sysdate) NOT NULL,
    modified     DATE
                     DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_ss_tag_ssid_tid_uq
    ON rhnSnapshotTag (snapshot_id, tag_id);

CREATE UNIQUE INDEX rhn_ss_tag_sid_tid_uq
    ON rhnSnapshotTag (server_id, tag_id);

CREATE INDEX rhn_ss_tag_tid_ssid_idx
    ON rhnSnapshotTag (tag_id, snapshot_id);

CREATE INDEX rhn_ss_tag_tid_sid_idx
    ON rhnSnapshotTag (tag_id, server_id);

