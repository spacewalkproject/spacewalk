--
-- Copyright (c) 2010 Red Hat, Inc.
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
--
--
--
CREATE TABLE rhnChannelContentSource
(
    source_id     NUMBER NOT NULL
                         CONSTRAINT rhn_ccs_src_id_fk
                             REFERENCES rhnContentSource (id)
                             ON DELETE CASCADE,
    channel_id    NUMBER NOT NULL
                         CONSTRAINT rhn_ccs_cid_fk
                             REFERENCES rhnChannel (id)
                             ON DELETE CASCADE,
    created          DATE
                         DEFAULT (sysdate) NOT NULL,
    modified         DATE
                         DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

ALTER TABLE rhnChannelContentSource
    ADD CONSTRAINT rhn_ccs_uq UNIQUE (source_id, channel_id)
    USING INDEX TABLESPACE [[4m_tbs]];
