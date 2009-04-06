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
	id			numeric not null
				constraint rhn_confrevision_id_pk primary key
--					using index tablespace [[4m_tbs]]
					,
	revision		numeric not null,
	-- if rhnConfigFile is deleted, it has a trigger that does
	-- rhn_config.delete_revision() for all the kids.
	config_file_id		numeric not null
				constraint rhn_confrevision_cfid_fk
					references rhnConfigFile(id),
	config_content_id	numeric not null
				constraint rhn_confrevision_ccid_fk
					references rhnConfigContent(id),
	config_info_id		numeric not null
				constraint rhn_confrevision_ciid_fk
					references rhnConfigInfo(id),
	delim_start		varchar(16) not null,
	delim_end		varchar(16) not null,
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null,
	config_file_type_id	numeric default 1 not null
				constraint rhn_conf_rev_cfti_fk
					references rhnConfigFileType (id),

	changed_by_id		numeric default null
				constraint rhn_confrevision_cid_fk
					references web_contact(id),

	constraint rhn_confrevision_cfid_rev_uq unique ( config_file_id, revision )
--		using index tablespace [[2m_tbs]]
);

alter table rhnConfigFile add constraint rhn_conffile_lcrid_fk foreign key (latest_config_revision_id)
                                references rhnConfigRevision(id)
                                on delete set null;


-- lemme know if we need more indices here.  We don't really support any 
-- interesting form of deleting rhnConfigContents or rhnConfigInfo,
-- so they don't need an index unless we want to look things up by them.

