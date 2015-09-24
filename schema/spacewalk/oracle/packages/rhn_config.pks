--
-- Copyright (c) 2008--2015 Red Hat, Inc.
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
