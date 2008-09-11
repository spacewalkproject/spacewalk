--
-- $Id$
--

create table
rhnServerActionScriptResult
(
	server_id		number
				constraint rhn_serveras_result_sid_nn not null
				constraint rhn_serveras_result_sid_fk
					references rhnServer(id),
	action_script_id	number
				constraint rhn_serveras_result_asid_nn not null
				constraint rhn_serveras_result_asid_fk
					references rhnActionScript(id)
					on delete cascade,
	output			blob,
	start_date		date
				constraint rhn_serveras_result_start_nn not null,
	stop_date		date
				constraint rhn_serveras_result_stop_nn not null,
	return_code		number
				constraint rhn_serveras_result_return_nn not null,
	created			date default(sysdate)
				constraint rhn_serveras_result_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_serveras_result_mod_nn not null
)
	tablespace [[blob]]
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_serveras_result_sas_uq
	on rhnServerActionScriptResult( server_id, action_script_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_serveras_result_asid_idx
	on rhnServerActionScriptResult( action_script_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create or replace trigger
rhn_serveras_result_mod_trig
before insert or update on rhnServerActionScriptResult
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
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
