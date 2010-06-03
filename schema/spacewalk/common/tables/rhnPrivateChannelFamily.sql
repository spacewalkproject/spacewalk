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


CREATE TABLE rhnPrivateChannelFamily
(
    channel_family_id  NUMBER NOT NULL
                           CONSTRAINT rhn_privcf_cfid_fk
                               REFERENCES rhnChannelFamily (id),
    org_id             NUMBER NOT NULL
                           CONSTRAINT rhn_privcf_oid_fk
                               REFERENCES web_customer (id)
                               ON DELETE CASCADE,
    max_members        NUMBER,
    current_members    NUMBER
                           DEFAULT (0) NOT NULL,
    max_flex           NUMBER,
    current_flex       NUMBER
                           DEFAULT (0) NOT NULL,
    created            DATE
                           DEFAULT (sysdate) NOT NULL,
    modified           DATE
                           DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_privcf_oid_cfid_uq
    ON rhnPrivateChannelFamily (org_id, channel_family_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_cfperm_cfid_oid_idx
    ON rhnPrivateChannelFamily (channel_family_id, org_id)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;

