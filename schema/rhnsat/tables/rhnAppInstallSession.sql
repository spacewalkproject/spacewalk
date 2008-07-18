--
-- $Id$
--

create sequence rhn_appinst_session_id_seq;

create table
rhnAppInstallSession
(
	id		number
			constraint rhn_appinst_session_id_nn not null,
	instance_id	number
			constraint rhn_appinst_session_iid_nn not null
			constraint rhn_appinst_session_iid_fk
				references rhnAppInstallInstance(id)
				on delete cascade,
	md5sum		varchar2(64),
	process_name	varchar2(32),
	step_number	number,
	user_id		number
			constraint rhn_appinst_session_uid_nn not null
			constraint rhn_appinst_session_uid_fk
				references web_contact(id),
	server_id	number
			constraint rhn_appinst_session_sid_nn not null
			constraint rhn_appinst_session_sid_fk
				references rhnServer(id),
	created		date default (sysdate)
			constraint rhn_appinst_session_creat_nn not null,
	modified	date default (sysdate)
			constraint rhn_appinst_session_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create or replace trigger
rhn_appinst_session_mod_trig
before insert or update on rhnAppInstallSession
for each row
begin
	:new.modified := sysdate;
end rhn_appinst_session_mod_trig;
/
show errors

create index rhn_appinst_session_id_iid_idx
	on rhnAppInstallSession( id, instance_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_appinst_session_iid_id_idx
    on rhnAppInstallSession( instance_id, id )
    tablespace [[4m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_appinst_sessn_uid_iid_idx
    on rhnAppInstallSession( user_id, instance_id )
    tablespace [[4m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_appinst_sessn_sid_iid_idx
    on rhnAppInstallSession( server_id, instance_id )
    tablespace [[4m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhnAppInstallSession add constraint rhn_appinst_sessiond_id_pk
	primary key ( id );

--
-- $Log$
-- Revision 1.2  2004/10/04 16:09:56  pjones
-- bugzilla: none -- somehow, I missed these indices and constraints last time.
--
-- Revision 1.1  2004/09/16 22:40:55  pjones
-- bugzilla: 132546 -- tables for application installation.
--
