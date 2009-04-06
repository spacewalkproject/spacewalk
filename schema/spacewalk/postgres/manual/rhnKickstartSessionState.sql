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

create sequence rhn_ks_session_state_id_seq;

create table
rhnKickstartSessionState
(
	id			numeric not null
				constraint rhn_ks_session_state_id_pk primary key
--					using index tablespace [[64k_tbs]]
                                ,
	label			varchar(64) not null
				constraint rhn_ks_session_state_label_uq unique 
--        			using index tablespace [[64k_tbs]]
                                ,
	name			varchar(128) not null,
	description		varchar(1024) not null,
	created			timestamp default (current_timestamp) not null,
	modified		timestamp default (current_timestamp) not null
)
  ;

/*
create or replace trigger
rhn_ks_session_state_mod_trig
before insert or update on rhnKickstartSessionState
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.5  2003/10/29 18:24:09  pjones
-- bugzilla: none -- stray newline prevents table creation.  grrr.
--
-- Revision 1.4  2003/10/08 19:23:09  pjones
-- bugzilla: none
--
-- change the constraint/trigger/sequence names again, this time less
-- consistant with everywhere else, but a lot more palitable
--
-- Revision 1.3  2003/10/08 19:02:03  pjones
-- bugzilla: none
--
-- missed missing c/m here
--
-- Revision 1.2  2003/10/08 18:51:44  pjones
-- bugzilla: none
--
-- Clean up the rhnKickstartSession stuff a bit.
--
