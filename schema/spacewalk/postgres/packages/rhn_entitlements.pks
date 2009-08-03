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

create schema rhn_entitlements;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_entitlements,' || setting where name = 'search_path';

    create or replace function remove_org_entitlements (
        org_id_in numeric
    ) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

    create or replace function entitlement_grants_service (
	    entitlement_in in varchar,
		service_level_in in varchar
	) returns numeric
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

	create or replace function lookup_entitlement_group (
		org_id_in in numeric,
		type_label_in in varchar default 'sw_mgr_entitled'
	) returns numeric
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

	create or replace function create_entitlement_group (
		org_id_in in numeric,
		type_label_in in varchar default 'sw_mgr_entitled'
	) returns numeric
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

   create or replace function can_entitle_server ( 
      server_id_in   in numeric, 
      type_label_in  in varchar
   )
   returns numeric
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

   create or replace function can_switch_base ( 
      server_id_in   in    integer, 
      type_label_in  in    varchar
   )
   returns numeric
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

   create or replace function find_compatible_sg (
      server_id_in in numeric,
      type_label_in in varchar
   )
   returns numeric
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

	create or replace function entitle_server (
		server_id_in in numeric,
		type_label_in in varchar default 'sw_mgr_entitled'
	) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

	create or replace function remove_server_entitlement (
		server_id_in in numeric,
		type_label_in in varchar default 'sw_mgr_entitled',
        repoll_virt_guests in numeric default 1
	) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

	create or replace function unentitle_server (
		server_id_in in numeric
	) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

    create or replace function repoll_virt_guest_entitlements(
        server_id_in in numeric
    ) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

	create or replace function get_server_entitlement (
		server_id_in in numeric
	) returns varchar[]
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

	create or replace function modify_org_service (
		org_id_in in numeric,
		service_label_in in varchar,
		enable_in in char
	) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

    create or replace function set_customer_enterprise (
		customer_id_in in numeric
	) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

	create or replace function set_customer_provisioning (
		customer_id_in in numeric
	) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

	create or replace function set_customer_nonlinux (
		customer_id_in in numeric
	) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

    create or replace function unset_customer_enterprise (
		customer_id_in in numeric
	) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

	create or replace function unset_customer_provisioning (
		customer_id_in in numeric
	) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

	create or replace function unset_customer_nonlinux (
		customer_id_in in numeric
	) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

    create or replace function assign_system_entitlement(
        group_label_in in varchar,
        from_org_id_in in numeric,
        to_org_id_in in numeric,
        quantity_in in numeric
    ) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

    create or replace function assign_channel_entitlement(
        channel_family_label_in in varchar,
        from_org_id_in in numeric,
        to_org_id_in in numeric,
        quantity_in in numeric
    ) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

    create or replace function activate_system_entitlement(
        org_id_in in numeric,
        group_label_in in varchar,
        quantity_in in numeric
    ) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

    create or replace function activate_channel_entitlement(
        org_id_in in numeric,
        channel_family_label_in in varchar,
        quantity_in in numeric
    ) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

    create or replace function set_group_count (
		customer_id_in in numeric,	-- customer_id
		type_in in char,			-- 'U' or 'S'
		group_type_in in numeric,	-- rhn[User|Server]GroupType.id
		quantity_in in numeric		-- quantity
    ) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

    create or replace function set_family_count (
		customer_id_in in numeric,		-- customer_id
		channel_family_id_in in numeric,	-- 246
		quantity_in in numeric			-- 3
    ) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

    -- this makes NO checks that the quantity is within max,
    -- so we should NEVER run this unless we KNOW that we won't be
    -- violating the max
    create or replace function entitle_last_modified_servers (
		customer_id_in in numeric,	-- customer_id
		type_label_in in varchar,	-- 'enterprise_entitled'
		quantity_in in numeric		-- 3
    ) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

	create or replace function prune_everything (
		customer_id_in in numeric
	) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

	create or replace function subscribe_newest_servers (
		customer_id_in in numeric
	) returns void
as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_entitlements')+1) ) where name = 'search_path';
