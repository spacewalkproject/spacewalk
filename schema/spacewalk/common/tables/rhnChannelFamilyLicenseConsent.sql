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


CREATE TABLE rhnChannelFamilyLicenseConsent
(
    channel_family_id  NUMBER NOT NULL 
                           CONSTRAINT rhn_cfl_consent_cfid_fk
                               REFERENCES rhnChannelFamily (id) 
                               ON DELETE CASCADE, 
    user_id            NUMBER NOT NULL 
                           CONSTRAINT rhn_cfl_consent_uid_fk
                               REFERENCES web_contact (id) 
                               ON DELETE CASCADE, 
    server_id          NUMBER NOT NULL 
                           CONSTRAINT rhn_cfl_consent_sid_fk
                               REFERENCES rhnServer (id), 
    created            DATE 
                           DEFAULT (sysdate) NOT NULL, 
    modified           DATE 
                           DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_cfl_consent_cf_s_uq
    ON rhnChannelFamilyLicenseConsent (channel_family_id, server_id)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_cfl_consent_uid_idx
    ON rhnChannelFamilyLicenseConsent (user_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE INDEX rhn_cfl_consent_sid_idx
    ON rhnChannelFamilyLicenseConsent (server_id)
    TABLESPACE [[8m_tbs]]
    NOLOGGING;

