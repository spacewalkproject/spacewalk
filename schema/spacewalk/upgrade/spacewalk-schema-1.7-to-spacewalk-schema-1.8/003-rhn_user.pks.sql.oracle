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

	function role_names (user_id_in in number) return varchar2;

end rhn_user;
/
SHOW ERRORS
