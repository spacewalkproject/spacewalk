--
-- $Id$
--

create table
rhnChannelPermission
(
	channel_id	number
			constraint rhn_cperm_cid_nn not null
			constraint rhn_cperm_cidffk
				references rhnChannel(id)
				on delete cascade,
	user_id		number
			constraint rhn_cperm_uid_nn not null
			constraint rhn_cperm_uid_fk
				references web_contact(id)
				on delete cascade,
	role_id		number
			constraint rhn_cperm_rid_nn not null
			constraint rhn_cperm_rid_fk
				references rhnChannelPermissionRole(id),
	created		date default(sysdate)
			constraint rhn_cperm_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_cperm_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_cperm_cid_uid_rid_idx
	on rhnChannelPermission(channel_id, user_id, role_id)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_cperm_mod_trig
before insert or update on rhnChannelPermission
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.1  2003/07/15 17:36:50  pjones
-- bugzilla: 98933
--
-- channel permissions
--
