--
-- $Id$
--

create sequence rhn_pushdispatch_id_seq;

create table
rhnPushDispatcher
(
		id		number
				constraint rhn_pushdispatch_id_nn not null
				constraint rhn_pushdispatch_id_pk primary key
					using index tablespace [[8m_tbs]],
		jabber_id	varchar2(128)
				constraint rhn_pushdispatch_jid_nn not null,
		last_checkin	date default sysdate
				constraint rhn_pushdispatch_lc_nn not null,
		hostname	varchar2(256)
				constraint rhn_pushdispatch_hn_nn not null,
		port		number
				constraint rhn_pushdispatch_port_nn not null,
		created		date default sysdate
				constraint rhn_pushdispatch_creat_nn not null,
		modified	date default sysdate
				constraint rhn_pushdispatch_mod_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_pushdispatch_jid_id_idx
	on rhnPushDispatcher( jabber_id, id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnPushDispatcher add constraint rhn_pushdispatch_jid_uq
	unique ( jabber_id );

create or replace trigger
rhn_pushdispatch_mod_trig
before insert or update on rhnPushDispatcher
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.2  2004/07/14 18:51:17  pjones
-- bugzilla: 127712 -- make jabber_id a string, fix the synonyms
--
-- Revision 1.1  2004/07/12 20:53:59  pjones
-- bugzilla: 172217 -- rhnPushDispatcher schema and change scripts
--
