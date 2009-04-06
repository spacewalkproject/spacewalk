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
rhnServerPath
(
	server_id		numeric
				not null
				constraint rhn_serverpath_sid_fk
					references rhnServer(id),
	proxy_server_id		numeric
				not null
				constraint rhn_serverpath_psid_fk
					references rhnServer(id),
	position		numeric
				not null,
	hostname		varchar(256)
				not null,
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null,
                                constraint rhn_serverpath_sid_pos_uq
                                unique( server_id, position )
--                              using index tablespace [[2m_tbs]]
                                ,
                                constraint rhn_serverpath_psid_sid_uq
                                unique( proxy_server_id, server_id )
--                              using index tablespace [[2m_tbs]]
)
  ;

/*
create or replace trigger rhn_serverpath_mod_trig
before insert or update on rhnServerPath
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.3  2004/02/20 16:21:09  pjones
-- bugzilla: none -- this should have made the delete_server() mods last week
--
-- Revision 1.2  2004/01/06 23:02:22  pjones
-- bugzilla: none -- cascade deletes on rhnServerPath
--
-- Revision 1.1  2003/12/10 16:37:47  pjones
-- bugzilla: 111448 -- tables for path to server
--
