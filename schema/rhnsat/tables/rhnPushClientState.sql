--
-- $Id$
--

create sequence rhn_pclient_state_id_seq;

create table
rhnPushClientState
(
	id		number
			constraint rhn_pclient_state_id_nn not null
			constraint rhn_pclient_state_id_pk primary key
				using index tablespace [[4m_tbs]],
	label		varchar2(64)
			constraint rhn_pclient_state_label_nn not null,
	name		varchar2(256)
			constraint rhn_pclient_state_name_nn not null,
	created		date default sysdate
			constraint rhn_pclient_state_created_nn not null,
	modified	date default sysdate
			constraint rhn_pclient_state_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_pclient_state_label_uq
	on rhnPushClientState( label )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_pclient_state_name_uq
	on rhnPushClientState( name )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_pclient_state_mod_trig
before insert or update on rhnPushClientState
for each row
begin
	:new.modified := sysdate;
end rhn_pclient_state_mod_trig;
/
show errors

--
-- $Log$
-- Revision 1.2  2004/10/08 21:09:24  pjones
-- bugzilla: none -- add name to end, so dbchange will actually work...
--
-- Revision 1.1  2004/10/07 20:07:50  misa
-- Push client table changes
--
