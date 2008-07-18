--
-- $Id$
--

create table
rhnChannelFamilyMembers
(
        channel_id      number
                        constraint rhn_cf_members_c_nn not null
                        constraint rhn_cf_members_c_fk
                                references rhnChannel(id) on delete cascade,
        channel_family_id number
                        constraint rhn_cf_family_nn not null
                        constraint rhn_cf_family_fk
                                references rhnChannelFamily(id),
        created         date default(sysdate)
                        constraint rhn_cf_member_cre_nn not null,
        modified        date default(sysdate)
                        constraint rhn_cf_member_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_cf_member_uq
	on rhnChannelFamilyMembers(channel_id, channel_family_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- a channel can be in at most one family
create unique index rhn_cf_c_uq
	on rhnChannelFamilyMembers(channel_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_cf_member_cf_c_idx
	on rhnChannelFamilyMembers(channel_family_id, channel_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create or replace trigger
rhn_cf_member_mod_trig
before insert or update on rhnChannelFamilyMembers
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.25  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.24  2002/05/10 21:54:44  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
--
