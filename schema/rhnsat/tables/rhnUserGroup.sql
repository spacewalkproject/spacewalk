--
-- $Id$
--

create table
rhnUserGroup
(
        id              number
                        constraint rhn_user_group_id_nn not null
                        constraint rhn_user_group_pk primary key
                                using index tablespace [[8m_tbs]]
				storage( pctincrease 1 freelists 16 )
				initrans 32,
        name            varchar2(64)
                        constraint rhn_user_group_name_nn not null,
        description     varchar2(1024)
                        constraint rhn_user_group_desc_nn not null,
        max_members     number,
        current_members number default(0)
                        constraint rhn_user_group_cm_nn not null,
        group_type      number
                        constraint rhn_usergroup_type_nn not null
                        constraint rhn_usergroup_type_fk
                                references rhnUserGroupType(id),
        org_id          number
                        constraint rhn_user_group_org_id_nn not null
                        constraint rhn_user_group_org_fk
                                references web_customer(id)
				on delete cascade,
        created         date default(sysdate)
                        constraint rhn_usergroup_type_created_nn not null,
        modified        date default(sysdate)
                        constraint rhn_usergroup_type_modified_nn not null
)
	storage ( pctincrease 1 freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.19  2003/03/14 23:15:14  pjones
-- org deletion
--
-- Revision 1.18  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.17  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
