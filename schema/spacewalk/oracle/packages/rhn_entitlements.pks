--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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
        quantity_in in number,
        flex_in in number
    );

    procedure activate_system_entitlement(
        org_id_in in number,
        group_label_in in varchar2,
        quantity_in in number
    );

    procedure activate_channel_entitlement(
        org_id_in in number,
        channel_family_label_in in varchar2,
        quantity_in in number,
        flex_in in number
    );

    procedure set_family_count (
		customer_id_in in number,		-- customer_id
		channel_family_id_in in number,	-- 246
		quantity_in in number,			-- 3
                flex_in in number
    );

    -- this makes NO checks that the quantity is within max,
    -- so we should NEVER run this unless we KNOW that we won't be
    -- violating the max
    procedure entitle_last_modified_servers (
		customer_id_in in number,	-- customer_id
		type_label_in in varchar2,	-- 'enterprise_entitled'
		quantity_in in number		-- 3
    );

	procedure subscribe_newest_servers (
		customer_id_in in number
	);
end rhn_entitlements;
/
show errors

