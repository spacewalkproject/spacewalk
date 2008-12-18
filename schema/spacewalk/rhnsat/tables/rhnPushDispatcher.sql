--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
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
	enable row movement
  ;

create index rhn_pushdispatch_jid_id_idx
	on rhnPushDispatcher( jabber_id, id )
	tablespace [[4m_tbs]]
  ;
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
--
-- Revision 1.2  2004/07/14 18:51:17  pjones
-- bugzilla: 127712 -- make jabber_id a string, fix the synonyms
--
-- Revision 1.1  2004/07/12 20:53:59  pjones
-- bugzilla: 172217 -- rhnPushDispatcher schema and change scripts
--
