--
-- $Id$
--

-- this is a generalized idea of how provides and requires work.
-- basicly, everything that provides or requires anything either puts an 
-- entry here, or uses one that already exists.  never duplicate, of course.
-- then rhnRequires and rhnProvides link packages to entries here.
-- kindof messy... If you've got a better idea, now's the time.
create table
rhnPackageCapability
(
	id		number
			constraint rhn_pkg_capability_id_nn not null
			constraint rhn_pkg_capability_id_pk primary key
				using index tablespace [[4m_tbs]],
	name		varchar(256)
                        constraint rhn_pkg_capability_name_nn not null,
	version		varchar(64), -- I really hate this.
	created		date default (sysdate)
			constraint rhn_pkg_capability_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_pkg_capability_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_pkg_capability_id_seq;

create unique index rhn_pkg_cap_name_version_uq
	on rhnPackageCapability(name, version)
	tablespace [[32m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_pkg_capability_mod_trig
before insert or update on rhnPackageCapability
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.6  2003/06/06 18:43:16  pjones
-- bugzilla: none
--
-- make version for rhnPackageCapability longer
--
-- Revision 1.5  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.4  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
