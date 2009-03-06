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

create sequence rhn_conffile_id_seq;

create table 
 rhnConfigFile
 (
	id			  numeric
				  constraint rhn_conffile_id_pk primary key
--				  using index tablespace [[2m_tbs]]
                                  ,
	config_channel_id	  numeric
				  not null
				  constraint rhn_conffile_ccid_fk
				  references rhnConfigChannel(id),
	config_file_name_id	  numeric
				  not null
				  constraint rhn_conffile_cfnid_fk
				  references rhnConfigFileName(id),
	latest_config_revision_id numeric,
--				  constraint rhn_conffile_lcrid_fk
--				  references rhnConfigRevision(id)
-- 				  on delete set null,
--(cross reference column has been altered in rhnConfigRevision)
	state_id		  numeric
				  not null
				  constraint rhn_conffile_sid_fk
				  references rhnConfigFileState(id),
	created			  date default(current_date)
				  not null,
	modified		  date default(current_date)
				  not null,
                                  constraint rhn_conffile_ccid_cfnid_uq
                                  unique ( config_channel_id, config_file_name_id )
)
  ;

create index rhn_conffile_cc_cfn_s_idx
	on rhnConfigFile( config_channel_id, config_file_name_id, state_id )
--     tablespace [[8m_tbs]]
       ;

create index rhn_cnf_fl_lcrid_idx
on rhnConfigFile ( latest_config_revision_id )
--      tablespace [[8m_tbs]]
        ;

/*
create or replace trigger
rhn_conffile_mod_trig
before insert or update on rhnConfigFile
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.12  2004/01/12 15:44:41  pjones
-- bugzilla: 113029 -- no cascade on config_channel_id; it's handled by the
-- trigger instead
--
-- Revision 1.11  2003/11/11 19:38:43  pjones
-- bugzilla: none -- delete cascades for rhnConfigFile and rhnConfigRevision
--
-- Revision 1.10  2003/11/10 21:04:22  pjones
-- bugzilla: none -- latest revision can't be nullable with this model.  I'm
-- really starting to like the "keep a seperate table of [config_file, revision]
-- which reflects latest" idea again.
--
-- Revision 1.9  2003/11/10 17:23:08  pjones
-- bugzilla: 109083 -- keep latest as an fk instead of a Y/N
--
-- Revision 1.8  2003/11/09 19:34:44  pjones
-- bugzilla: 109083 -- use rhnConfigFileName for path
--
-- Revision 1.7  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
--
