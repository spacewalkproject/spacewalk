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
		id		numeric
				constraint rhn_pushdispatch_id_pk primary key
--				using index tablespace [[8m_tbs]]
                                ,
		jabber_id	varchar(128)
				not null
                                constraint rhn_pushdispatch_jid_uq unique,
		last_checkin	date default current_date
				not null,
		hostname	varchar(256)
				not null,
		port		numeric
				not null,
		created		date default current_date
				not null,
		modified	date default current_date
				not null
)
  ;

create index rhn_pushdispatch_jid_id_idx
	on rhnPushDispatcher( jabber_id, id )
--	tablespace [[4m_tbs]]
        ;

/*
create or replace trigger
rhn_pushdispatch_mod_trig
before insert or update on rhnPushDispatcher
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.2  2004/07/14 18:51:17  pjones
-- bugzilla: 127712 -- make jabber_id a string, fix the synonyms
--
-- Revision 1.1  2004/07/12 20:53:59  pjones
-- bugzilla: 172217 -- rhnPushDispatcher schema and change scripts
--
