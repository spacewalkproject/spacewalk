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


CREATE TABLE rhnChannelFamilyLicense
(
    channel_family_id  NUMBER NOT NULL 
                           CONSTRAINT rhn_cfl_cfid_fk
                               REFERENCES rhnChannelFamily (id) 
                               ON DELETE CASCADE, 
    license_path       VARCHAR2(1000) NOT NULL, 
    created            DATE 
                           DEFAULT (sysdate) NOT NULL, 
    modified           DATE 
                           DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_cf_license_cfid_uq
    ON rhnChannelFamilyLicense (channel_family_id)
    TABLESPACE [[64k_tbs]];

