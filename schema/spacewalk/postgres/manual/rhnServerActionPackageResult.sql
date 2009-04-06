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
rhnServerActionPackageResult
(
	server_id		numeric
				not null
				constraint rhn_sap_result_sid_fk
				references rhnServer(id),
	action_package_id	numeric
				not null
				constraint rhn_sap_result_apid_fk
				references rhnActionPackage(id)
				on delete cascade,
	result_code		numeric
				not null,
	stdout			bytea,
	stderr			bytea,
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null,
                                constraint rhn_sap_result_sid_apid_uq
                                unique( server_id, action_package_id )
--                              using index tablespace [[4m_tbs]]
)
--	tablespace [[blob]]
  ;

/*
create or replace trigger
rhn_sap_result_mod_trig
before insert or update on rhnServerActionPackageResult
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.3  2004/02/24 17:35:42  pjones
-- bugzilla: none -- fix rhnActionPackageRemovalFailure to be removed properly
-- with rhnServer; also add rhnServerActionPackageResult and
-- rhnServerActionScriptResult to be deleted.
--
-- Revision 1.2  2004/02/16 19:54:37  pjones
-- bugzilla: none -- rename with "server", add server_id
--
-- Revision 1.1  2004/02/10 23:41:01  pjones
-- bugzilla: none -- rename the result table to be more generic
--
-- Revision 1.2  2004/02/10 23:37:37  pjones
-- bugzilla: none -- typo fix
--
-- Revision 1.1  2004/02/10 23:31:12  pjones
-- bugzilla: none -- add install result table
--
