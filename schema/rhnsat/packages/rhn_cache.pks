--
-- $Id$
--

create or replace package
rhn_cache
is
	version varchar2(100) := '$Id: rhn_cache.pks 45933 2004-07-02 19:14:32Z pjones $';

	-- this searches out all users who get perms...
	procedure update_perms_for_server(
		server_id_in in number
	);

	procedure update_perms_for_user(
		user_id_in in number
	);

	procedure update_perms_for_server_group(
		server_group_id_in in number
	);
end rhn_cache;
/
show errors

--
-- $Log$
-- Revision 1.1  2004/07/02 19:14:32  pjones
-- 125937 -- tools to manipulate rhnUserServerPerms when appropriate.
--

