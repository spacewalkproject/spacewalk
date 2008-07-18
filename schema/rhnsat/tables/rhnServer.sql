--
-- $Id$
--

create table
rhnServer
(
        id              number
			constraint rhn_server_id_nn not null
                        constraint rhn_server_id_pk primary key
	                        using index tablespace [[4m_tbs]]
				storage( pctincrease 1 freelists 16 ),
        org_id          number
                        constraint rhn_server_oid_nn not null
                        constraint rhn_server_oid_fk
                                references web_customer(id)
				on delete cascade,
        digital_server_id varchar(64)
			constraint rhn_server_dsi_nn not null,
	server_arch_id	number
			constraint rhn_server_said_nn not null
			constraint rhn_server_said_fk
				references rhnServerArch(id),
        os              varchar(64)
			constraint rhn_server_os_nn not null,
        release         varchar(64)
			constraint rhn_server_release_nn not null,
        name            varchar(128),
        description     varchar(256),
        info            varchar(128),
        secret          varchar(32)
			constraint rhn_server_secret_nn not null,
	creator_id	number
			constraint rhn_server_creator_fk
				references web_contact(id)
				on delete set null,
	auto_deliver	char(1) default 'N'
	    	    	constraint rhn_server_auto_deliver_nn not null
			constraint rhn_server_deliver_ck
				check (auto_deliver in ('Y', 'N')),
	auto_update     char(1) default 'N'
	    	    	constraint rhn_server_auto_update_nn not null
			constraint rhn_server_update_ck
				check (auto_update in ('Y', 'N')),
	running_kernel  varchar2(64),
        last_boot       number default 0
			constraint rhn_server_lb_nn not null,
	provision_state_id number
			constraint rhn_server_psid_fk
				references rhnProvisionState(id),
	channels_changed date,
        created         date default (sysdate)
			constraint rhn_server_created_nn not null,
        modified        date default (sysdate)
			constraint rhn_server_modified_nn not null
)
	storage ( pctincrease 1 freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_server_id_seq start with 1000010000 order;

create unique index rhn_server_dsid_uq
	on rhnServer(digital_server_id)
	tablespace [[8m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32;

create index rhn_server_oid_id_idx
	on rhnServer(org_id,id)
        tablespace [[4m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32
	nologging;

create index rhn_server_created_id_idx
	on rhnServer(created,id)
        tablespace [[4m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32
	nologging;

-- this keeps delete_user from being _too_ slow
create index rhn_server_creator_idx
	on rhnServer(creator_id)
	tablespace [[2m_tbs]]
	storage ( pctincrease 1 freelists 16 )
	initrans 32
	nologging;

create or replace trigger
rhn_server_mod_trig
before insert or update on rhnServer
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.33  2004/04/07 14:42:13  bretm
-- bugzilla:  119871
--
-- needed a new flag to keep track of last time rhnServerChannels changed...
--
-- Revision 1.32  2003/10/06 15:17:58  pjones
-- bugzilla: none
--
-- drop auto_snapshot from rhnServer
--
-- Revision 1.31  2003/09/30 14:38:21  pjones
-- bugzilla: none
--
-- changes for this got checked in (so it went through QA and such)
-- but this file didn't get changed
--
-- Revision 1.30  2003/09/08 13:30:23  bretm
-- bugzilla:  none
--
-- fix a typo that somehow slipped in...
--
-- Revision 1.29  2003/09/05 20:45:07  pjones
-- bugzilla: 103313
--
-- schema to represent a system's provisioning state.  We still need data here.
--
-- Revision 1.28  2003/03/17 16:31:25  pjones
-- use "on delete set null" where applicable
--
-- Revision 1.27  2003/03/15 00:23:06  pjones
-- bugzilla: none
--
-- rhnServer didn't match the db; fixed now, also got rid of the nn on
-- creator_id so we can null it on the delete_user case
--
-- Revision 1.26  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.25  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.24  2002/12/15 06:03:46  pjones
-- kill rhn_server_said_id_idx, it isn't really selective at all.
--
-- Revision 1.23  2002/11/14 17:31:37  pjones
-- more arch changes -- remove the old fields
--
-- Revision 1.22  2002/11/13 22:45:20  pjones
-- add appropriate arch fields.
-- haven't deleted the old ones yet though
--
-- Revision 1.21  2002/10/07 20:43:31  cturner
-- add index on created to rhnServer
--
-- Revision 1.20  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
