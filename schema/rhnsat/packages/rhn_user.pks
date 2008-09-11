--
-- $Id$
--

create or replace
package rhn_user
is
	version varchar2(100) := '$Id: rhn_user.pks 45937 2004-07-02 19:19:33Z pjones $';

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

	procedure add_users_to_usergroups(
		user_id_in in number
	);

	procedure remove_from_usergroup(
		user_id_in in number,
		user_group_id_in in number
	);

	procedure remove_users_from_servergroups(
		user_id_in in number
	);
end rhn_user;
/
SHOW ERRORS
