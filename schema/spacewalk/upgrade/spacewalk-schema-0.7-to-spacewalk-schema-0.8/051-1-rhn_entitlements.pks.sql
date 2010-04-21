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

create or replace
package rhn_entitlements
is
	body_version varchar2(100) := '';

   type ents_array is varray(10) of rhnServerGroupType.label%TYPE;

    procedure remove_org_entitlements (
        org_id_in number
    );

    function entitlement_grants_service (
	    entitlement_in in varchar2,
		service_level_in in varchar2
	) return number;

	function lookup_entitlement_group (
		org_id_in in number,
		type_label_in in varchar2 := 'sw_mgr_entitled'
	) return number;

	function create_entitlement_group (
		org_id_in in number,
		type_label_in in varchar2 := 'sw_mgr_entitled'
	) return number;

   function can_entitle_server (
      server_id_in   in number,
      type_label_in  in varchar2
   )
   return number;

   function can_switch_base (
      server_id_in   in    integer,
      type_label_in  in    varchar2
   )
   return number;

   function find_compatible_sg (
      server_id_in in number,
      type_label_in in varchar2,
      sgid_out out number
   )
   return boolean;

	procedure entitle_server (
		server_id_in in number,
		type_label_in in varchar2 := 'sw_mgr_entitled'
	);

	procedure remove_server_entitlement (
		server_id_in in number,
		type_label_in in varchar2 := 'sw_mgr_entitled',
        repoll_virt_guests in number := 1
	);

	procedure unentitle_server (
		server_id_in in number
	);

    procedure repoll_virt_guest_entitlements(
        server_id_in in number
    );

	function get_server_entitlement (
		server_id_in in number
	) return ents_array;

	procedure modify_org_service (
		org_id_in in number,
		service_label_in in varchar2,
		enable_in in char
	);

    procedure set_customer_enterprise (
		customer_id_in in number
	);

	procedure set_customer_provisioning (
		customer_id_in in number
	);

	procedure set_customer_nonlinux (
		customer_id_in in number
	);

    procedure unset_customer_enterprise (
		customer_id_in in number
	);

	procedure unset_customer_provisioning (
		customer_id_in in number
	);

	procedure unset_customer_nonlinux (
		customer_id_in in number
	);

    procedure assign_system_entitlement(
        group_label_in in varchar2,
        from_org_id_in in number,
        to_org_id_in in number,
        quantity_in in number
    );

    procedure assign_channel_entitlement(
        channel_family_label_in in varchar2,
        from_org_id_in in number,
        to_org_id_in in number,
        quantity_in in number
    );

    procedure activate_system_entitlement(
        org_id_in in number,
        group_label_in in varchar2,
        quantity_in in number
    );

    procedure activate_channel_entitlement(
        org_id_in in number,
        channel_family_label_in in varchar2,
        quantity_in in number
    );

    procedure set_group_count (
		customer_id_in in number,	-- customer_id
		type_in in char,			-- 'U' or 'S'
		group_type_in in number,	-- rhn[User|Server]GroupType.id
		quantity_in in number,		-- quantity
                update_family_countsYN in number := 1 -- call update_family_counts inside
    );

    procedure set_family_count (
		customer_id_in in number,		-- customer_id
		channel_family_id_in in number,	-- 246
		quantity_in in number			-- 3
    );

    -- this makes NO checks that the quantity is within max,
    -- so we should NEVER run this unless we KNOW that we won't be
    -- violating the max
    procedure entitle_last_modified_servers (
		customer_id_in in number,	-- customer_id
		type_label_in in varchar2,	-- 'enterprise_entitled'
		quantity_in in number		-- 3
    );

	procedure prune_everything (
		customer_id_in in number
	);

	procedure subscribe_newest_servers (
		customer_id_in in number
	);
end rhn_entitlements;
/
show errors

--
-- Revision 1.19  2004/05/26 19:45:48  pjones
-- bugzilla: 123639
-- 1) reformat "entitlement_grants_service"
-- 2) make the .pks and .pkb be in the same order.
-- 3) add "modify_org_service" (to be used instead of set_customer_SERVICELEVEL)
-- 4) add monitoring specific data.
--
-- Revision 1.18  2004/02/19 20:17:49  pjones
-- bugzilla: 115896 -- add sgt and oet data for nonlinux, add
-- [un]set_customer_nonlinux
--
-- Revision 1.17  2004/01/13 23:37:08  pjones
-- bugzilla: none -- mate provisioning and management slots.
--
-- Revision 1.16  2003/09/23 22:14:41  bretm
-- bugzilla:  103655
--
-- need something in the db that knows provisioning boxes are management boxes too, etc.
--
-- Revision 1.15  2003/09/19 22:35:07  pjones
-- bugzilla: none
--
-- provisioning and config management entitlement support
--
-- Revision 1.14  2003/09/02 22:22:54  pjones
-- bugzilla: none
--
-- attempt to autoentitle upon entitlement changes
--
-- Revision 1.13  2003/06/05 21:43:40  pjones
-- bugzilla: none
--
-- add rhn_entitlements.prune_everything(customer_id_in in number);
--
-- Revision 1.12  2003/05/22 16:01:14  pjones
-- reformat
-- remove update_[server|user]group_counts (unused)
--
-- Revision 1.11  2002/06/03 16:07:29  pjones
-- make prune_group and prune_family update respective max_members
-- correctly.
--
-- Revision 1.10  2002/05/29 19:10:31  pjones
-- code to entitle the last N modified servers to a particular service
-- level
--
-- Revision 1.9  2002/05/10 22:08:23  pjones
-- id/log
--
