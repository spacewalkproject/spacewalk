--
-- $Id$
--

create table
rhnKickstartPackage
(
	kickstart_id		number
				constraint rhn_kspackage_ksid_nn not null
				constraint rhn_kspackage_ksid_fk
					references rhnKSData(id)
					on delete cascade,
	package_name_id		number
				constraint rhn_kspackage_pnid_nn not null
				constraint rhn_kspackage_pnid_fk
					references rhnPackageName(id),
	created			date default(sysdate)
				constraint rhn_kspackage_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_kspackage_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_kspackage_id_idx
	on rhnKickstartPackage( kickstart_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_kspackage_mod_trig
before insert or update on rhnKickstartPackage
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.2  2003/09/17 16:45:37  rnorwood
-- bugzilla: 103307 - rename rhnKickstart due to extreme weirdness with Oracle::DBD.
--
-- Revision 1.1  2003/09/11 20:55:42  pjones
-- bugzilla: 104231
--
-- tables to handle kickstart data
--
