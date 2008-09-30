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
rhnActionConfigFileName
(
	action_id		number
				constraint rhn_actioncf_name_aid_nn not null,
	server_id		number
				constraint rhn_actioncf_name_sid_nn not null,
	config_file_name_id	number
				constraint rhn_actioncf_name_cfnid_nn not null
				constraint rhn_actioncf_name_cfnid_fk
					references rhnConfigFileName(id),
	config_revision_id	number
				constraint rhn_actioncf_name_crid_fk
					references rhnConfigRevision(id)
					on delete set null,
	failure_id		number
				constraint rhn_actioncf_failure_id_fk
					references rhnConfigFileFailure(id),
	created			date default(sysdate)
				constraint rhn_actioncf_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_actioncf_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

alter table rhnActionConfigFileName
	add constraint rhn_actioncf_name_aid_sid_fk
	foreign key ( server_id, action_id )
	references rhnServerAction( server_id, action_id )
	on delete cascade;

create unique index rhn_actioncf_name_asc_uq
	on rhnActionConfigFileName ( action_id, server_id, config_file_name_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_actioncf_name_sac_uq
        on rhnActionConfigFileName ( server_id, action_id, config_file_name_id )
        tablespace [[2m_tbs]]
        storage ( freelists 16 )
        initrans 32;

create index rhn_act_cnfg_fn_crid_idx
on rhnActionConfigFileName ( config_revision_id )
        tablespace [[2m_tbs]]
        storage ( freelists 16 )
        initrans 32;

create or replace trigger
rhn_actioncf_name_mod_trig
before insert or update on rhnActionConfigFileName
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.9  2003/12/16 17:07:05  pjones
-- bugzilla: 112234 -- add config_revision_id so we can track what files
-- match with which revisions when it's known
--
-- Revision 1.8  2003/11/26 21:20:19  misa
-- bugzilla: 111051  Thou shalt not exclude this table from satellite builds
--
-- Revision 1.7  2003/11/15 01:45:33  misa
-- bugzilla: 107284  Schema for storing missing files
--
-- Revision 1.6  2003/11/12 15:31:21  pjones
-- bugzilla: none -- add rhnActionConfigFileName back
--
-- Revision 1.4  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
--
-- Revision 1.3  2003/10/16 19:17:49  pjones
-- bugzilla: none
-- needs to reference a server, too
--
-- Revision 1.2  2003/10/15 19:26:16  pjones
-- bugzilla: none
-- should have been action_id, not action_config_file_id
--
-- Revision 1.1  2003/10/14 21:08:08  pjones
-- bugzilla: 107050
-- schema for associating actions with config files
--
