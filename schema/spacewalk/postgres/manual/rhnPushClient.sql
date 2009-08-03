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

create sequence rhn_pclient_id_seq;

create table
rhnPushClient
(
	id		   numeric
			   not null
			   constraint rhn_pclient_id_pk primary key
--			   using index tablespace [[4m_tbs]]
                           ,
	name		   varchar(64)
			   not null
                           constraint rhn_pclient_name_uq unique
--                         using index tablespace [[8m_tbs]]
                           ,
	server_id	   numeric
			   not null
                           constraint rhn_pclient_sid_uq unique
--                         using index tablespace [[2m_tbs]]
                           ,
	jabber_id	   varchar(128),
	shared_key	   varchar(64)
			   not null,
        state_id           numeric
			   not null
                           references rhnPushClientState(id),
        next_action_time    date,
        last_message_time   date,
        last_ping_time      date,
	created		    date default current_date
			    not null,
	modified	    date default current_date
			    not null
)
  ;

/*
create or replace trigger
rhn_pclient_mod_trig
before insert or update on rhnPushClient
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.2  2004/10/07 20:07:50  misa
-- Push client table changes
--
-- Revision 1.1  2004/06/23 00:59:29  pjones
-- bugzilla: none -- table for misa's "push" stuff.  Misa, I _really_ need a
-- bugzilla on this...
--
