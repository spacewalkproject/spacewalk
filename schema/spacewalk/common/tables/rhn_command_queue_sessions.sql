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


CREATE TABLE rhn_command_queue_sessions
(
    contact_id        NUMBER NOT NULL, 
    session_id        VARCHAR2(255), 
    expiration_date   DATE, 
    last_update_user  VARCHAR2(40), 
    last_update_date  DATE
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_command_queue_sessions IS 'cqses  command queue sessions';

CREATE UNIQUE INDEX rhn_cqses_cid_uq
    ON rhn_command_queue_sessions (contact_id)
    TABLESPACE [[4m_tbs]];

ALTER TABLE rhn_command_queue_sessions
    ADD CONSTRAINT rhn_cqses_cntct_contact_idfk FOREIGN KEY (contact_id)
    REFERENCES web_contact (id);

