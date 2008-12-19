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

create table
rhnActionConfigDateFile
(
	action_id		number
				constraint rhn_actioncd_file_aid_nn not null
				constraint rhn_actioncd_file_aid_fk
					references rhnAction(id)
					on delete cascade,
	file_name		varchar2(512)
				constraint rhn_actioncd_file_fn_nn not null,
	-- I could make this a lookup table, if anybody wants me to.
	-- right now it's 'W' for whitelist, 'B' for blacklist.
	file_type		char(1)
				constraint rhn_actioncd_file_ft_nn not null
				constraint rhn_actioncd_file_ft_ck
					check (file_type in ('W','B')),
	created			date default(sysdate)
				constraint rhn_actioncd_file_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_actioncd_file_mod_nn not null
)
	enable row movement
  ;

create index rhn_actioncd_file_aid_fn_idx
	on rhnActionConfigDateFile(action_id, file_name)
	tablespace [[4m_tbs]]
  ;

create or replace trigger
rhn_actioncd_file_mod_trig
before insert or update on rhnActionConfigDateFile
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
--
-- Revision 1.2  2003/12/17 22:08:53  pjones
-- bugzilla: none -- move this column to the parent, not the blacklist info
--
-- Revision 1.1  2003/12/17 15:15:45  pjones
-- bugzilla: none ? -- add schema for import by date action
--
