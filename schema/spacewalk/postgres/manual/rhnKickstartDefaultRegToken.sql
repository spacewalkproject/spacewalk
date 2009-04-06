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
rhnKickstartDefaultRegToken
(
	kickstart_id		numeric
				not null
				constraint rhn_ksdrt_ksid_fk
				references rhnKSData(id)
				on delete cascade,
	regtoken_id		numeric
				not null
				constraint rhn_ksdrt_rtid_fk
				references rhnRegToken(id)
				on delete cascade,
	created			date default (current_date)
				not null,
	modified		date default (current_date)
				not null
)
  ;

create index rhn_ksdrt_ksid_rtid_idx
	on rhnKickstartDefaultRegToken( kickstart_id, regtoken_id )
--	tablespace [[8m_tbs]]
  ;

-- supports the "on delete cascade"
create index rhn_ksdrt_rtid_idx
	on rhnKickstartDefaultRegToken( regtoken_id )
--	tablespace [[2m_tbs]]
  ;
/*
create or replace trigger
rhn_ksdrt_mod_trig
before insert or update on rhnKickstartDefaultRegToken
for each row
begin
	:new.modified := sysdate;
end rhn_ksdrt_mod_trig;
/
show errors
*/
--
--
-- Revision 1.2  2004/05/25 19:04:23  pjones
-- bugzilla: none -- remove the unique constraint, it's bogus.
--
-- Revision 1.1  2004/05/24 20:28:00  pjones
-- bugzilla: 121395 -- add support for more than one default activation key
-- for a kickstart session
--
