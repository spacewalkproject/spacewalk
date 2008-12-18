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

-- When we ask "show me files that changed between X and Y dates", the dates
-- get stored here.
--

create table
rhnActionConfigDate
(
	action_id		number
				constraint rhn_actioncd_aid_nn not null
				constraint rhn_actioncd_aid_fk
					references rhnAction(id)
					on delete cascade,
	start_date		date
				constraint rhn_actioncd_start_nn not null,
	end_date		date,
	import_contents		char(1)
				constraint rhn_actioncd_file_ic_nn not null
				constraint rhn_actioncd_file_ic_ck
					check (import_contents in ('Y','N')),
	created			date default(sysdate)
				constraint rhn_actioncd_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_actioncd_mod_nn not null
)
	enable row movement
  ;

create unique index rhn_actioncd_aid_uq
	on rhnActionConfigDate( action_id )
	tablespace [[2m_tbs]]
  ;

create or replace trigger
rhn_actioncd_mod_trig
before insert or update on rhnActionConfigDate
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
--
-- Revision 1.3  2004/03/15 16:41:57  pjones
-- bugzilla: 118245 -- on delete cascades for deleting actions
--
-- Revision 1.2  2003/12/17 22:08:53  pjones
-- bugzilla: none -- move this column to the parent, not the blacklist info
--
-- Revision 1.1  2003/12/17 15:15:45  pjones
-- bugzilla: none ? -- add schema for import by date action
--
