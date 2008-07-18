--
-- $Id$
--

create table
rhnServerPackageArchCompat
(
        server_arch_id	number
                        constraint rhn_sp_ac_said_nn not null
                        constraint rhn_sp_ac_said_fk 
				references rhnServerArch(id),
	package_arch_id	number
			constraint rhn_sp_ac_paid_nn not null
			constraint rhn_sp_ac_paid_fk
				references rhnPackageArch(id),
        preference      number
                        constraint rhn_sp_ac_pref_nn not null,
	created		date default(sysdate)
			constraint rhn_sp_ac_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_sp_ac_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_sp_ac_said_paid_pref
	on rhnServerPackageArchCompat(
		server_arch_id, package_arch_id, preference)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnServerPackageArchCompat add constraint rhn_sp_ac_said_paid_uq
	unique ( server_arch_id, package_arch_id );

create index rhn_sp_ac_paid_said_pref
	on rhnServerPackageArchCompat(
	 	package_arch_id, server_arch_id, preference)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

alter table rhnServerPackageArchCompat add constraint rhn_sp_ac_pref_said_uq
	unique ( preference, server_arch_id )
	using index tablespace [[64k_tbs]];

create or replace trigger
rhn_sp_ac_mod_trig
before insert or update on rhnServerPackageArchCompat
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/11/13 21:50:21  pjones
-- new arch system
--
