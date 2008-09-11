--
-- $Id$
--/

create table
rhnPackageGroup
(
        id              number
			constraint rhn_package_group_id_nn not null
                        constraint rhn_package_group_id_pk primary key
                        using index tablespace [[2m_tbs]],
        name            varchar2(100)
			constraint rhn_package_group_name_nn not null,
        created         date default(sysdate)
			constraint rhn_package_group_created_nn not null,
        modified        date default(sysdate)
			constraint rhn_package_group_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_package_group_id_seq;

create unique index rhn_package_group_name_uq
	on rhnPackageGroup(name)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_package_group_mod_trig
before insert or update on rhnPackageGroup
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.11  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.10  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
