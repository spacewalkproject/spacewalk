
create table
rhnUserDefaultSystemGroups
(
	user_id		number
			constraint rhn_udsg_uid_nn not null
			constraint rhn_udsg_uid_fk
				references web_contact(id)
				on delete cascade,
	system_group_id	number
			constraint rhn_udsg_cid_nn not null
			constraint rhn_udsg_cidffk
				references rhnServerGroup(id)
				on delete cascade
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_udsg_uid_sgid_idx
	on rhnUserDefaultSystemGroups(user_id, system_group_id)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_udsg_sgid_uid_idx
	on rhnUserDefaultSystemGroups(system_group_id, user_id)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
