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
-- $Id$
--

create sequence rhn_ks_session_state_id_seq;

create table
rhnKickstartSessionState
(
	id			number
				constraint rhn_ks_session_state_id_nn not null
				constraint rhn_ks_session_state_id_pk primary key
					using index tablespace [[64k_tbs]],
	label			varchar2(64)
				constraint rhn_ks_session_state_label_nn not null,
	name			varchar2(128)
				constraint rhn_ks_session_state_name_nn not null,
	description		varchar2(1024)
				constraint rhn_ks_session_state_desc_nn not null,
	created			date default(sysdate)
				constraint rhn_ks_session_state_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_ks_session_state_mod_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_ks_session_state_label_uq
	on rhnKickstartSessionState(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_ks_session_state_mod_trig
before insert or update on rhnKickstartSessionState
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
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
