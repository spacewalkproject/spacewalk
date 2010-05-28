--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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

    PROCEDURE license_consent(channel_id_in IN NUMBER, user_id_in IN NUMBER, server_id_in IN NUMBER);
    FUNCTION get_license_path(channel_id_in IN NUMBER) RETURN VARCHAR2;

    PROCEDURE unsubscribe_server(server_id_in IN NUMBER, channel_id_in NUMBER, immediate_in NUMBER := 1, unsubscribe_children_in number := 0,
                                 deleting_server in number := 0,
                                 update_family_countsYN IN NUMBER := 1);
    PROCEDURE subscribe_server(server_id_in IN NUMBER, channel_id_in NUMBER, immediate_in NUMBER := 1, user_id_in number := null, recalcfamily_in number := 1);
	
    function can_server_consume_virt_channl(
        server_id_in IN NUMBER,
        family_id_in in number)
    return number;

    FUNCTION guess_server_base(server_id_in IN NUMBER) RETURN NUMBER;

    FUNCTION base_channel_for_release_arch(release_in in varchar2, 
	server_arch_in in varchar2, org_id_in in number := -1, 
	user_id_in in number := null) RETURN number;

    FUNCTION base_channel_rel_archid(release_in in varchar2, 
	server_arch_id_in in number, org_id_in in number := -1, 
	user_id_in in number := null) RETURN number;

    FUNCTION channel_priority(channel_id_in in number) RETURN number;
    
    PROCEDURE bulk_server_base_change(channel_id_in IN NUMBER, set_label_in IN VARCHAR2, set_uid_in IN NUMBER);
    procedure bulk_server_basechange_from(
	set_label_in in varchar2,
	set_uid_in in number,
	old_channel_id_in in number,
	new_channel_id_in in number);

    procedure bulk_guess_server_base(
	set_label_in in varchar2,
	set_uid_in in number);

    procedure bulk_guess_server_base_from(
	set_label_in in varchar2,
	set_uid_in in number,
	channel_id_in in number);

    PROCEDURE clear_subscriptions(server_id_in IN NUMBER, deleting_server in number := 0,
                                update_family_countsYN IN NUMBER := 1);
    
    FUNCTION available_family_subscriptions(channel_family_id_in IN NUMBER, org_id_in IN NUMBER) RETURN NUMBER;

    function channel_family_current_members(channel_family_id_in IN NUMBER,
                                            org_id_in IN NUMBER)
    return number;

    PROCEDURE update_family_counts(channel_family_id_in IN NUMBER, org_id_in IN NUMBER);
    PROCEDURE update_group_family_counts(group_label_in IN VARCHAR2, org_id_in IN NUMBER);
    FUNCTION family_for_channel(channel_id_in IN NUMBER) RETURN NUMBER;

    FUNCTION available_chan_subscriptions(channel_id_in IN NUMBER, org_id_in IN NUMBER) RETURN NUMBER;

    procedure entitle_customer(customer_id_in in number, channel_family_id_in in number, quantity_in in number);
    procedure set_family_maxmembers(customer_id_in in number, channel_family_id_in in number, quantity_in in number);
    procedure unsubscribe_server_from_family(server_id_in in number, channel_family_id_in in number);

    procedure delete_server_channels(server_id_in in number);
    procedure refresh_newest_package(channel_id_in in number, caller_in in varchar2 := '(unknown)');
    
    function get_org_id(channel_id_in in number) return number;
    PRAGMA RESTRICT_REFERENCES(get_org_id, WNDS, RNPS, WNPS);

    function get_org_access(channel_id_in in number, org_id_in in number) return number;
    PRAGMA RESTRICT_REFERENCES(get_org_access, WNDS, RNPS, WNPS);
    
    function get_cfam_org_access(cfam_id_in in number, org_id_in in number) return number;

    function user_role_check_debug(channel_id_in in number, user_id_in in number, role_in in varchar2, reason_out out varchar2)
    	RETURN NUMBER;
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
                               date_to_use in date := sysdate );

    PROCEDURE  update_channels_by_package ( package_id_in in number, date_to_use in date := sysdate );

     PROCEDURE update_channels_by_errata ( errata_id_in number, date_to_use in date := sysdate );


    PRAGMA RESTRICT_REFERENCES(org_channel_setting, WNDS, RNPS, WNPS);

END rhn_channel;
/
SHOW ERRORS

--
-- Revision 1.37  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
-- Revision 1.36  2004/03/26 18:11:32  rbb
-- Bugzilla:  114057
--
-- Add a script to determine channel priority.
--
-- Revision 1.35  2004/02/17 20:16:52  pjones
-- bugzilla: none -- add cvs tags into the package as long as we're touching
-- it anyway
--
-- Revision 1.34  2003/11/13 18:13:09  cturner
-- pragmas can now return now that rhn_user pragmas are fixed
--
-- Revision 1.32  2003/09/22 21:00:40  cturner
-- add method for easy acl check
--
-- Revision 1.31  2003/09/17 22:14:11  misa
-- bugzilla: 103639  Changes to allow me to move the base channel guess into plsql
--
-- Revision 1.30  2003/07/24 16:44:16  misa
-- bugzilla: none  A function more usable on the rhnapp side
--
-- Revision 1.29  2003/07/24 14:00:17  misa
-- bugzilla: none  PRAGMA RESTRICT_REFERENCES good
--
-- Revision 1.28  2003/07/23 21:59:19  cturner
-- rework how rhnUserChannel works; move to plsql for speed and maintenance
--
-- Revision 1.27  2003/07/21 17:49:12  pjones
-- bugzilla: none
--
-- add optional user for subscribe_server
--
-- Revision 1.26  2002/12/19 18:13:42  misa
-- Added caller with a default value
--
-- Revision 1.25  2002/12/11 22:18:46  pjones
-- rhnChannelNewestPackage
--
-- Revision 1.24  2002/11/21 22:08:11  pjones
-- make unsubscribe_channels have a "unsubscribe_children_in number := 0"
-- argument so that you can tell it to unsubscribe children.
--
-- Also, make it raise an exception instead of silent failure in the
-- other case.
--
-- Revision 1.23  2002/11/18 17:20:50  pjones
-- this should have gone back too
--
-- Revision 1.22  2002/11/13 23:16:18  pjones
-- lookup_*_arch()
--
-- Revision 1.21  2002/10/07 20:01:59  rnorwood
-- guess base channel for ssm and single system
--
-- Revision 1.20  2002/10/02 19:21:03  bretm
-- o  3rd party channel schema changes, no more clobs...
--
-- Revision 1.19  2002/09/20 19:21:58  bretm
-- o  more 3rd party channel stuff...
--
-- Revision 1.18  2002/06/12 22:33:03  pjones
-- procedure bulk_guess_server_base_from(
--     set_label_in in varchar2,
--     set_uid_in in number,
--     channel_id_in in number);
--
-- for bretm
--
-- Revision 1.17  2002/06/12 22:12:25  pjones
-- procedure bulk_guess_server_base(
--     set_label_in in varchar2,
--     set_uid_in in number);
--
-- for bretm
--
-- Revision 1.16  2002/06/12 19:37:55  pjones
-- bulk_server_basechange_from(
-- 	set_label_in in varchar2,
-- 	set_uid_in in number,
-- 	old_channel_id_in in number,
-- 	new_channel_id_in in number
-- );
--
-- for bretm
--
-- Revision 1.15  2002/05/10 22:08:22  pjones
-- id/log
--
