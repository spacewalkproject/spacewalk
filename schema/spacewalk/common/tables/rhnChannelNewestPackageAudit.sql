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


CREATE TABLE rhnChannelNewestPackageAudit
(
    refresh_time  DATE 
                      DEFAULT (sysdate) NOT NULL, 
    channel_id    NUMBER NOT NULL 
                      CONSTRAINT rhn_cnp_at_cid_fk
                          REFERENCES rhnChannel (id) 
                          ON DELETE CASCADE, 
    caller        VARCHAR2(256) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_cnp_a_t_all_idx
    ON rhnChannelNewestPackageAudit (channel_id, refresh_time, caller)
    TABLESPACE [[8m_tbs]];

