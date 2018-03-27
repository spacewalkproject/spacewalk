--
-- Copyright (c) 2008--2018 Red Hat, Inc.
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

CREATE OR REPLACE
PACKAGE rhn_channel
IS
	version varchar2(100) := '';

    CURSOR server_base_subscriptions(server_id_in NUMBER) IS
    	   SELECT C.id
	     FROM rhnChannel C, rhnServerChannel SC
	    WHERE C.id = SC.channel_id
	      AND SC.server_id = server_id_in
	      AND C.parent_channel IS NULL;

    CURSOR check_server_subscription(server_id_in NUMBER, channel_id_in NUMBER) IS
           SELECT channel_id
	     FROM rhnServerChannel
	    WHERE server_id = server_id_in
	      AND channel_id = channel_id_in;

    CURSOR check_server_parent_membership(server_id_in NUMBER, channel_id_in NUMBER) IS
    	   SELECT C.id
	     FROM rhnChannel C, rhnServerChannel SC
	    WHERE C.parent_channel = channel_id_in
	      AND C.id = SC.channel_id
	      AND SC.server_id = server_id_in;

    CURSOR channel_family_perm_cursor(channel_family_id_in NUMBER, org_id_in NUMBER) IS
           SELECT *
	     FROM rhnOrgChannelFamilyPermissions
	    WHERE channel_family_id = channel_family_id_in
	      AND org_id = org_id_in;


    PROCEDURE unsubscribe_server(server_id_in IN NUMBER, channel_id_in NUMBER, immediate_in NUMBER := 1, unsubscribe_children_in number := 0,
                                 deleting_server in number := 0);
    PROCEDURE subscribe_server(server_id_in IN NUMBER, channel_id_in NUMBER, immediate_in NUMBER := 1, user_id_in number := null);

    FUNCTION guess_server_base(server_id_in IN NUMBER) RETURN NUMBER;

    FUNCTION base_channel_for_release_arch(release_in in varchar2,
	server_arch_in in varchar2, org_id_in in number := -1,
	user_id_in in number := null) RETURN number;

    FUNCTION base_channel_rel_archid(release_in in varchar2,
	server_arch_id_in in number, org_id_in in number := -1,
	user_id_in in number := null) RETURN number;

    FUNCTION channel_priority(channel_id_in in number) RETURN number;

    PROCEDURE clear_subscriptions(server_id_in IN NUMBER, deleting_server in number := 0);

    FUNCTION family_for_channel(channel_id_in IN NUMBER) RETURN NUMBER;

    PROCEDURE unsubscribe_server_from_family(server_id_in in number, channel_family_id_in in number);

    PROCEDURE refresh_newest_package(channel_id_in in number,
                                     caller_in in varchar2 := '(unknown)',
                                     package_name_id_in in number := null);

    FUNCTION get_org_id(channel_id_in in number) return number;
    PRAGMA RESTRICT_REFERENCES(get_org_id, WNDS, RNPS, WNPS);

    function get_org_access(channel_id_in in number, org_id_in in number) return number;
    PRAGMA RESTRICT_REFERENCES(get_org_access, WNDS, RNPS, WNPS);

    function get_cfam_org_access(cfam_id_in in number, org_id_in in number) return number;

    function user_role_check_debug(channel_id_in in number, user_id_in in number, role_in in varchar2)
        RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES(user_role_check_debug, WNDS, RNPS, WNPS);

    function user_role_check(channel_id_in in number, user_id_in in number, role_in in varchar2)
    	RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES(user_role_check, WNDS, RNPS, WNPS);

    function loose_user_role_check(channel_id_in in number, user_id_in in number, role_in in varchar2)
    	RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES(loose_user_role_check, WNDS, RNPS, WNPS);

    function direct_user_role_check(channel_id_in in number, user_id_in in number, role_in in varchar2)
    	RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES(direct_user_role_check, WNDS, RNPS, WNPS);

    function shared_user_role_check(channel_id in number, user_id in number, role in varchar2)
    	RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES(shared_user_role_check, WNDS, RNPS, WNPS);

    function org_channel_setting(channel_id_in in number, org_id_in in number, setting_in in varchar2)
    	RETURN NUMBER;

    PROCEDURE update_channel ( channel_id_in in number, invalidate_ss in number := 0,
                               date_to_use in timestamp with local time zone := current_timestamp );

    PROCEDURE  update_channels_by_package ( package_id_in in number, date_to_use in timestamp with local time zone := current_timestamp );

     PROCEDURE update_channels_by_errata ( errata_id_in number, date_to_use in timestamp with local time zone := current_timestamp );


    PRAGMA RESTRICT_REFERENCES(org_channel_setting, WNDS, RNPS, WNPS);

    PROCEDURE update_needed_cache(channel_id_in in number);

    procedure set_comps(channel_id_in in number, path_in in varchar2, comps_type_id_in in number, timestamp_in in varchar2);

END rhn_channel;
/
SHOW ERRORS
