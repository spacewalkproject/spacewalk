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
	id		number
			constraint rhn_pclient_id_nn not null
			constraint rhn_pclient_id_pk primary key
				using index tablespace [[4m_tbs]],
	name		varchar2(64)
			constraint rhn_pclient_name_nn not null,
	server_id	number
			constraint rhn_pclient_sid_nn not null,
	jabber_id	varchar2(128),
	shared_key	varchar2(64)
			constraint rhn_pclient_skey_nn not null,
        state_id        number
			constraint rhn_pclient_stid_nn not null
                        references rhnPushClientState(id),
        next_action_time    date,
        last_message_time   date,
        last_ping_time      date,
	created		date default sysdate
			constraint rhn_pclient_created_nn not null,
	modified	date default sysdate
			constraint rhn_pclient_modified_nn not null
)
	enable row movement
  ;

create unique index rhn_pclient_name_uq
	on rhnPushClient( name )
	tablespace [[8m_tbs]]
  ;

create unique index rhn_pclient_sid_uq
	on rhnPushClient( server_id )
	tablespace [[2m_tbs]]
  ;

create or replace trigger
rhn_pclient_mod_trig
before insert or update on rhnPushClient
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
--
-- Revision 1.2  2004/10/07 20:07:50  misa
-- Push client table changes
--
-- Revision 1.1  2004/06/23 00:59:29  pjones
-- bugzilla: none -- table for misa's "push" stuff.  Misa, I _really_ need a
-- bugzilla on this...
--
