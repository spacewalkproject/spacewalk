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

create sequence rhn_pclient_state_id_seq;

create table
rhnPushClientState
(
	id		numeric
			constraint rhn_pclient_state_id_pk primary key
--			using index tablespace [[4m_tbs]]
                        ,
	label		varchar(64)
			not null
                        constraint rhn_pclient_state_label_uq unique
--                      using index tablespace [[4m_tbs]]
                        ,
	name		varchar(256)
			not null
                        constraint rhn_pclient_state_name_uq unique
--                      using index tablespace [[4m_tbs]]
                        ,
	created		date default current_date
			not null,
	modified	date default current_date
			not null
)
  ;

/*
create or replace trigger
rhn_pclient_state_mod_trig
before insert or update on rhnPushClientState
for each row
begin
	:new.modified := sysdate;
end rhn_pclient_state_mod_trig;
/
show errors
*/
--
--
-- Revision 1.2  2004/10/08 21:09:24  pjones
-- bugzilla: none -- add name to end, so dbchange will actually work...
--
-- Revision 1.1  2004/10/07 20:07:50  misa
-- Push client table changes
--
