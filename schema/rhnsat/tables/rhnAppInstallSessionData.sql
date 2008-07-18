--
-- $Id$
--

create sequence rhn_appinst_sdata_id_seq;

create table
rhnAppInstallSessionData
(
	id		number
			constraint rhn_appinst_sdata_id_nn not null,
	session_id	number
			constraint rhn_appinst_sdata_sid_nn not null
			constraint rhn_appinst_sdata_sid_fk
				references rhnAppInstallSession(id)
				on delete cascade,
	key		varchar2(64)
			constraint rhn_appinst_sdata_k_nn not null,
	value		varchar2(2048),
	extra_data	blob,
	created		date default (sysdate)
			constraint rhn_appinst_sdata_creat_nn not null,
	modified	date default (sysdate)
			constraint rhn_appinst_sdata_mod_nn not null
)
	tablespace [[blob]]
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create or replace trigger
rhn_appinst_sdata_mod_trig
before insert or update on rhnAppInstallSessionData
for each row
begin
	:new.modified := sysdate;
end rhn_appinst_sdata_mod_trig;
/
show errors

create index rhn_appinst_sdata_id_idx
	on rhnAppInstallSessionData( id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnAppInstallSessionData add constraint rhn_appinst_sdata_id_pk
	primary key ( id );

create index rhn_appinst_sdata_sid_k_id_idx
	on rhnAppInstallSessionData( session_id, key, id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnAppInstallSessionData add constraint rhn_appinst_sdata_sid_k_uq
	unique ( session_id, key );

--
-- $Log$
-- Revision 1.4  2004/10/04 16:09:56  pjones
-- bugzilla: none -- somehow, I missed these indices and constraints last time.
--
-- Revision 1.3  2004/09/27 17:10:06  pjones
-- bugzilla: 132131 -- change the storage parameters so this table is in the
-- safer "blob" tablespace.
--
-- Revision 1.2  2004/09/27 13:47:12  rnorwood
-- bugzilla: 132131 - Change script and updated .sql file for rhnAppInstallSessionData
--
-- Revision 1.1  2004/09/16 22:40:55  pjones
-- bugzilla: 132546 -- tables for application installation.
--
