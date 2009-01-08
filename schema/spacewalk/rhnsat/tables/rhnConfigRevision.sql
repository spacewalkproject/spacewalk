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

create sequence rhn_confrevision_id_seq;

create table
rhnConfigRevision
(
	id			number
				constraint rhn_confrevision_id_nn not null
				constraint rhn_confrevision_id_pk primary key
					using index tablespace [[4m_tbs]],
	revision		number
				constraint rhn_confrevision_rev_nn not null,
	-- if rhnConfigFile is deleted, it has a trigger that does
	-- rhn_config.delete_revision() for all the kids.
	config_file_id		number
				constraint rhn_confrevision_cfid_nn not null
				constraint rhn_confrevision_cfid_fk
					references rhnConfigFile(id),
	config_content_id	number
				constraint rhn_confrevision_ccid_nn not null
				constraint rhn_confrevision_ccid_fk
					references rhnConfigContent(id),
	config_info_id		number
				constraint rhn_confrevision_ciid_nn not null
				constraint rhn_confrevision_ciid_fk
					references rhnConfigInfo(id),
	delim_start		varchar2(16)
				constraint rhn_confrevision_dstart_nn not null,
	delim_end		varchar2(16)
				constraint rhn_confrevision_dend_nn not null,
	created			date default(sysdate)
				constraint rhn_confrevision_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_confrevision_mod_nn not null,
   config_file_type_id number default 1
                  constraint rhn_conf_rev_cfti_fk references rhnConfigFileType (id)
                  constraint rhn_conf_rev_cfti_nn not null,

        changed_by_id number
        default null
        constraint rhn_confrevision_cid_fk references web_contact(id) 
)
	enable row movement
  ;

-- lemme know if we need more indices here.  We don't really support any 
-- interesting form of deleting rhnConfigContents or rhnConfigInfo,
-- so they don't need an index unless we want to look things up by them.

create unique index rhn_confrevision_cfid_rev_uq
	on rhnConfigRevision( config_file_id, revision )
	tablespace [[2m_tbs]]
  ;

--
--
-- Revision 1.11  2005/02/11 01:27:04  jslagle
-- Fixed typo error.
--
-- Revision 1.10  2005/02/11 00:49:32  jslagle
-- Added config_file_type_id fk reference to rhnConfigFileType
--
-- Revision 1.9  2004/01/08 00:03:37  pjones
-- bugzilla: 113029 -- rhn_config.delete_revision() and delete trigger on
-- rhnConfigFile
--
-- Revision 1.8  2003/11/14 21:00:44  pjones
-- bugzilla: none -- snapshot invalid on config rev removal
--
-- Revision 1.7  2003/11/11 19:38:43  pjones
-- bugzilla: none -- delete cascades for rhnConfigFile and rhnConfigRevision
--
-- Revision 1.6  2003/11/11 17:01:01  pjones
-- bugzilla: none -- add unique on (config_file_id, revision)
--
-- Revision 1.5  2003/11/10 17:23:08  pjones
-- bugzilla: 109083 -- keep latest as an fk instead of a Y/N
--
-- Revision 1.4  2003/11/09 17:31:37  pjones
-- bugzilla: 109083 -- rhnConfigRevision now has a "latest" field.  It should
-- probably get maintained by a trigger, but let's wait on that for now.
--
-- Revision 1.3  2003/11/07 20:15:51  pjones
-- bugzilla: none typo fixes
--
-- Revision 1.2  2003/11/07 19:55:20  pjones
-- bugzilla: none
-- s/rhnRevision/rhnConfigRevision/ and such.
--
-- Revision 1.1  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
--
