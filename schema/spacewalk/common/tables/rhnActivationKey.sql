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


CREATE TABLE rhnActivationKey
(
    token          VARCHAR2(48) NOT NULL 
                       CONSTRAINT rhn_act_key_token_uq UNIQUE, 
    reg_token_id   NUMBER NOT NULL 
                       CONSTRAINT rhn_act_key_reg_tid_fk
                           REFERENCES rhnRegToken (id) 
                           ON DELETE CASCADE, 
    ks_session_id  NUMBER 
                       CONSTRAINT rhn_act_key_ks_sid_fk
                           REFERENCES rhnKickstartSession (id) 
                           ON DELETE CASCADE, 
    created        DATE 
                       DEFAULT (sysdate) NOT NULL, 
    modified       DATE 
                       DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_act_key_kssid_rtid_idx
    ON rhnActivationKey (ks_session_id, reg_token_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE INDEX rhn_act_key_rtid_idx
    ON rhnActivationKey (reg_token_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

