--
-- $Id$
--

create table
rhnRegToken
(
	id		number
			constraint rhn_reg_token_id_nn not null
			constraint rhn_reg_token_pk primary key,
	org_id		number
			constraint rhn_reg_token_oid_nn not null
			constraint rhn_reg_token_oid_fk
				references web_customer(id)
				on delete cascade,
	user_id		number
			constraint rhn_reg_token_uid_fk
				references web_contact(id)
				on delete set null,
	server_id	number
			constraint rhn_reg_token_sid_fk
				references rhnServer(id),
	note		varchar2(2048)
			constraint rhn_reg_token_note_nn not null,
	usage_limit     number default 0,
        disabled        number default 0
	    	    	constraint rhn_reg_token_def_nn not null,
	deploy_configs	char(1) default('Y')
			constraint rhn_reg_token_deployconfs_nn not null
			constraint rhn_reg_token_deployconfs_ck
				check (deploy_configs in ('Y','N'))
)
	storage( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_reg_token_org_id_idx
	on rhnRegToken(org_id, id)
	tablespace [[64k_tbs]]
	storage( freelists 16 )
	initrans 32
	nologging;

create index rhn_reg_token_uid_idx
	on rhnRegToken ( user_id )
	tablespace [[64k_tbs]]
	storage( freelists 16 )
	initrans 32
	nologging;

create index rhn_reg_token_sid_idx
	on rhnRegToken( server_id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create sequence rhn_reg_token_seq;

-- $Log$
-- Revision 1.17  2004/05/27 16:56:17  pjones
-- bugzilla: 124360 -- remove the user_id delete cascade.
--
-- Revision 1.16  2004/03/04 20:23:28  pjones
-- bugzilla: none -- diffs from dev and qa
--
-- Revision 1.15  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.14  2003/12/18 16:33:39  rnorwood
-- bugzilla: 111564 - change on delete set null to on delete cascade.
--
-- Revision 1.13  2003/11/12 22:29:20  pjones
-- bugzilla: none -- rhnRegToken.deploy_configs
--
-- Revision 1.12  2003/10/08 17:25:44  misa
-- bugzilla: 106573  Schema for rhnActivationKey
--
-- Revision 1.11  2003/09/16 16:33:25  pjones
-- bugzilla: 103322
--
-- need nullable serverId, so says rnorwood.
--
-- Revision 1.10  2003/04/14 16:10:09  pjones
-- bugzilla: none
--
-- Another cornercase tested, another change in the tree...
--
-- Revision 1.9  2003/04/10 15:23:47  pjones
-- bugzilla: none
--
-- add this here too, not just in changes
--
-- Revision 1.8  2003/03/27 21:10:23  pjones
-- indices to support faster user deletion
--
-- Revision 1.7  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.6  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.5  2002/12/05 17:08:21  rnorwood
-- SQL changes for regToken usage_limit
--
-- Revision 1.4  2002/07/10 20:24:20  pjones
-- re-add the constraint mentioned yesterday
--
-- Revision 1.3  2002/06/21 16:20:58  pjones
-- remove not null constraint on rhnRegToken.entitlement_level for Rob
--
-- Revision 1.2  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
