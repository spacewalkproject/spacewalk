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
rhnServerActionScriptResult
(
	server_id		numeric
				not null
				constraint rhn_serveras_result_sid_fk
				references rhnServer(id),
	action_script_id	numeric
				not null
				constraint rhn_serveras_result_asid_fk
				references rhnActionScript(id)
				on delete cascade,
	output			bytea,
	start_date		date
				not null,
	stop_date		date
				not null,
	return_code		numeric
				not null,
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null,
                                constraint rhn_serveras_result_sas_uq
                                unique( server_id, action_script_id )
--                              using index  tablespace [[4m_tbs]]
)
--	tablespace [[blob]]
  ;

create index rhn_serveras_result_asid_idx
	on rhnServerActionScriptResult( action_script_id )
--	tablespace [[4m_tbs]]
	;

/*
create or replace trigger
rhn_serveras_result_mod_trig
before insert or update on rhnServerActionScriptResult
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.5  2004/03/04 20:23:28  pjones
-- bugzilla: none -- diffs from dev and qa
--
-- Revision 1.4  2004/02/25 14:53:51  pjones
-- bugzilla: none -- remove stray comma
--
-- Revision 1.3  2004/02/24 17:35:42  pjones
-- bugzilla: none -- fix rhnActionPackageRemovalFailure to be removed properly
-- with rhnServer; also add rhnServerActionPackageResult and
-- rhnServerActionScriptResult to be deleted.
--
-- Revision 1.2  2004/02/19 15:43:43  pjones
-- bugzilla: 115898 -- add timeoute, start/stop times, and return code
--
-- Revision 1.1  2004/02/17 00:19:54  pjones
-- bugzilla: 115898 -- tables for scripts in actions and their results
--
