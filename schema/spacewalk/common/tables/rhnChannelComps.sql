--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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


CREATE TABLE rhnChannelComps
(
    id                 NUMBER NOT NULL
                           CONSTRAINT rhn_channelcomps_id_pk PRIMARY KEY,
    channel_id         NUMBER NOT NULL
                           CONSTRAINT rhn_channelcomps_cid_fk
                               REFERENCES rhnChannel (id)
                               ON DELETE CASCADE
			constraint rhn_channelcomps_cid_uq unique
			using index tablespace [[2m_tbs]],
    relative_filename  VARCHAR2(256) NOT NULL,
    last_modified      timestamp with local time zone
                           DEFAULT (current_timestamp) NOT NULL,
    created            timestamp with local time zone
                           DEFAULT (current_timestamp) NOT NULL,
    modified           timestamp with local time zone
                           DEFAULT (current_timestamp) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE SEQUENCE rhn_channelcomps_id_seq START WITH 101;

