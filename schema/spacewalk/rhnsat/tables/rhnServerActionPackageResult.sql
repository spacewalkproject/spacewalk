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
	server_id		number
				constraint rhn_sap_result_sid_nn not null
				constraint rhn_sap_result_sid_fk
					references rhnServer(id),
	action_package_id	number
				constraint rhn_sap_result_apid_nn not null
				constraint rhn_sap_result_apid_fk
					references rhnActionPackage(id)
					on delete cascade,
	result_code		number
				constraint rhn_sap_result_rc_nn not null,
	stdout			blob,
	stderr			blob,
	created			date default(sysdate)
				constraint rhn_sap_result_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_sap_result_mod_nn not null
)
	tablespace [[blob]]
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_sap_result_sid_apid_uq
	on rhnServerActionPackageResult( server_id, action_package_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_sap_result_mod_trig
before insert or update on rhnServerActionPackageResult
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

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
