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


CREATE TABLE rhnRegTokenGroups
(
    token_id         NUMBER NOT NULL 
                         CONSTRAINT rhn_reg_tok_grp_id_fk
                             REFERENCES rhnRegToken (id) 
                             ON DELETE CASCADE, 
    server_group_id  NUMBER NOT NULL 
                         CONSTRAINT rhn_reg_tok_grp_sgs_fk
                             REFERENCES rhnServerGroup (id) 
                             ON DELETE CASCADE
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_reg_tok_grp_uq
    ON rhnRegTokenGroups (token_id, server_group_id)
    TABLESPACE [[4m_tbs]];

