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
--
--
--

create table rhnRegTokenEntitlement (
   reg_token_id         numeric not null
                        constraint rhn_reg_tok_ent_rtid_fk references rhnRegToken(id)
                        on delete cascade,
   server_group_type_id numeric not null
                        constraint rhn_reg_tok_ent_sgtid_fk references rhnServerGroupType(id)
                        on delete cascade
)
 ;


create unique index rhn_rte_rtid_sgtid_uq_idx
on rhnRegTokenEntitlement (reg_token_id, server_group_type_id)
--   tablespace [[64k_tbs]]
--   nologging
;




            
