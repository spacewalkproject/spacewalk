--
-- Copyright (c) 2008--2011 Red Hat, Inc.
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

create or replace
package rhn_user
is
	version varchar2(100) := '';

    function check_role(user_id_in in number, role_in in varchar2) return number;
    PRAGMA RESTRICT_REFERENCES(check_role, WNDS, RNPS, WNPS);

    function check_role_implied(user_id_in in number, role_in in varchar2) return number;
    PRAGMA RESTRICT_REFERENCES(check_role_implied, WNDS, RNPS, WNPS);

    function get_org_id(user_id_in in number) return number;
    PRAGMA RESTRICT_REFERENCES(get_org_id, WNDS, RNPS, WNPS);
    
	function find_mailable_address(user_id_in in number) return varchar2;

	procedure add_servergroup_perm(
		user_id_in in number,
		server_group_id_in in number
	);

	procedure remove_servergroup_perm(
		user_id_in in number,
		server_group_id_in in number
	);

	procedure add_to_usergroup(
		user_id_in in number,
		user_group_id_in in number
	);

	procedure remove_from_usergroup(
		user_id_in in number,
		user_group_id_in in number
	);

end rhn_user;
/
SHOW ERRORS
