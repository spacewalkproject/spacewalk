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


CREATE TABLE rhnRegTokenEntitlement
(
    reg_token_id          NUMBER NOT NULL 
                              CONSTRAINT rhn_reg_tok_ent_rtid_fk
                                  REFERENCES rhnRegToken (id) 
                                  ON DELETE CASCADE, 
    server_group_type_id  NUMBER NOT NULL 
                              CONSTRAINT rhn_reg_tok_ent_sgtid_fk
                                  REFERENCES rhnServerGroupType (id) 
                                  ON DELETE CASCADE
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_rte_rtid_sgtid_uq_idx
    ON rhnRegTokenEntitlement (reg_token_id, server_group_type_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

