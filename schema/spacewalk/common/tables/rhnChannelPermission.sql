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


CREATE TABLE rhnChannelPermission
(
    channel_id  NUMBER NOT NULL
                    CONSTRAINT rhn_cperm_cidffk
                        REFERENCES rhnChannel (id)
                        ON DELETE CASCADE,
    user_id     NUMBER NOT NULL
                    CONSTRAINT rhn_cperm_uid_fk
                        REFERENCES web_contact (id)
                        ON DELETE CASCADE,
    role_id     NUMBER NOT NULL
                    CONSTRAINT rhn_cperm_rid_fk
                        REFERENCES rhnChannelPermissionRole (id),
    created     DATE
                    DEFAULT (sysdate) NOT NULL,
    modified    DATE
                    DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_cperm_cid_uid_rid_idx
    ON rhnChannelPermission (channel_id, user_id, role_id)
    TABLESPACE [[2m_tbs]];

