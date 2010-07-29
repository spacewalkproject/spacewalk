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

create or replace package
rhn_config
is
	procedure prune_org_configs (
		org_id_in in number,
		total_in in number
	);

	function insert_revision (
		revision_in in number,
		config_file_id_in in number,
		config_content_id_in in number,
		config_info_id_in in number,
      config_file_type_id_in number := 1
	) return number;

	procedure delete_revision (
		config_revision_id_in in number,
		org_id_in in number := -1
	);

	function get_latest_revision (
		config_file_id_in in number
	) return number;

	function insert_file (
		config_channel_id_in in number,
		name_in in varchar2
	) return number;

	procedure delete_file (
		config_file_id_in in number
	);

	function insert_channel (
		org_id_in in number,
		type_in in varchar2,
		name_in in varchar2,
		label_in in varchar2,
		description_in in varchar2
	) return number;

	procedure delete_channel (
		config_channel_id_in in number
	);
end rhn_config;
/
show errors

--
--
-- Revision 1.8  2005/02/16 14:03:35  jslagle
-- bz #148844
-- Changed insert_revision function to take a config_file_type_id instead of label
--
-- Revision 1.7  2005/02/15 02:42:59  jslagle
-- bz #147860
-- insert_revision function now takes a rhnConfigFileType label as a parameter instead of an id
--
-- Revision 1.6  2005/02/14 22:45:23  jslagle
-- bz#147860
-- Update rhn_config package body and specification for additional column to rhnConfigRevision
--
-- Revision 1.5  2004/01/09 17:39:45  pjones
-- bugzilla: 113029 -- need to do functions for deleting rhnConfigChannel,
-- too, or we can't prune rhnConfigFile when we do.
--
-- Revision 1.4  2004/01/08 19:46:31  pjones
-- bugzilla: 113029 -- insert/delete for rhnConfigFile and rhnConfigRevision
--
-- Revision 1.3  2004/01/08 00:30:10  pjones
-- bugzilla: 113029 -- more deletion of config files and revisions
--
-- Revision 1.2  2004/01/08 00:03:37  pjones
-- bugzilla: 113029 -- rhn_config.delete_revision() and delete trigger on
-- rhnConfigFile
--
-- Revision 1.1  2003/12/19 22:07:30  pjones
-- bugzilla: 112392 -- quota support for config files
--
