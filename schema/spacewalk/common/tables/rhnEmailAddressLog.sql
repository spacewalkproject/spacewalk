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


CREATE TABLE rhnEmailAddressLog
(
    user_id  NUMBER NOT NULL 
                 CONSTRAINT rhn_eaddresslog_uid_fk
                     REFERENCES web_contact (id) 
                     ON DELETE CASCADE, 
    address  VARCHAR2(128) NOT NULL, 
    reason   VARCHAR2(4000), 
    created  DATE 
                 DEFAULT (sysdate) NOT NULL
)
TABLESPACE [[8m_data_tbs]]
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_eaddresslog_uid_idx
    ON rhnEmailAddressLog (user_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_eaddresslog_a_idx
    ON rhnEmailAddressLog (address)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_eaddresslog_created_idx
    ON rhnEmailAddressLog (created)
    TABLESPACE [[4m_tbs]];

