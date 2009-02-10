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

create sequence rhn_cfstate_id_seq;

create table
rhnConfigFileState
(
	id		numeric not null
			constraint rhn_cfstate_id_pk primary key
--				using index tablespace [[2m_tbs]],
	label		varchar(32) not null,
	name		varchar(256) not null,
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null,
			constraint rhn_cfstate_label_id_uq unique ( label, id )
--		        tablespace [[4m_tbs]]
)
  ;


/*create or replace trigger
rhn_cfstate_mod_trig
before insert or update on rhnConfigFileState
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/

--
--
-- Revision 1.1  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
--
