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


CREATE TABLE rhnActionTransactions
(
    action_id      NUMBER NOT NULL 
                       CONSTRAINT rhn_at_aid_fk
                           REFERENCES rhnAction (id) 
                           ON DELETE CASCADE, 
    from_trans_id  NUMBER NOT NULL 
                       CONSTRAINT rhn_at_ftid_fk
                           REFERENCES rhnTransaction (id) 
                           ON DELETE CASCADE, 
    to_trans_id    NUMBER NOT NULL 
                       CONSTRAINT rhn_at_ttid_fk
                           REFERENCES rhnTransaction (id) 
                           ON DELETE CASCADE
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_at_aid_ftid_ttid_uq
    ON rhnActionTransactions (action_id, from_trans_id, to_trans_id)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_act_trans_from_to_idx
    ON rhnActionTransactions (from_trans_id, to_trans_id, action_id)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_act_trans_to_from_idx
    ON rhnActionTransactions (to_trans_id, from_trans_id, action_id)
    TABLESPACE [[64k_tbs]];

