--
-- $Id$
--

create table rhnRegTokenEntitlement (
   reg_token_id         number
                        constraint rhn_reg_tok_ent_rtid_nn not null
                        constraint rhn_reg_tok_ent_rtid_fk references rhnRegToken(id)
                        on delete cascade,
   server_group_type_id number
                        constraint rhn_reg_tok_ent_sgtid_nn not null
                        constraint rhn_reg_tok_ent_sgtid_fk references rhnServerGroupType(id)
                        on delete cascade
)
   storage( freelists 16 )
   initrans 32;


create unique index rhn_rte_rtid_sgtid_uq_idx
on rhnRegTokenEntitlement (reg_token_id, server_group_type_id)
   tablespace [[64k_tbs]]
   storage( freelists 16 )
   initrans 32
   nologging;




            
