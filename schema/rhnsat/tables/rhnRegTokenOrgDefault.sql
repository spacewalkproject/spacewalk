--
-- $Id$
--

create table
rhnRegTokenOrgDefault
(
	org_id		number
			constraint rhn_reg_token_def_oid_nn not null
			constraint rhn_reg_token_def_oid_fk
				references web_customer(id)
				on delete cascade,
	reg_token_id	number
			constraint rhn_reg_token_def_tokid_fk
				references rhnRegToken(id)
				on delete cascade
)
	enable row movement
	;

create unique index rhn_reg_token_def_org_id_idx
	on rhnRegTokenOrgDefault(org_id)
	storage( freelists 16 )
	initrans 32;

create index rhn_reg_token_def_uid_idx
	on rhnRegTokenOrgDefault (reg_token_id, org_id)
	storage( freelists 16 )
	initrans 32;
	
-- $Log$
-- Revision 1.1  2003/11/07 04:10:51  cturner
-- Bugzilla: 109295, add default flag for reg tokens
--
