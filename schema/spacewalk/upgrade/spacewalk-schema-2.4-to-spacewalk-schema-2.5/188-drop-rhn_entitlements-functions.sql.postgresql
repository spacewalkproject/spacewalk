-- oracle equivalent source sha1 b04dab2ff31049a8744e5ce1531ccd8b00152bbc

update pg_settings set setting = 'rhn_entitlements,' || setting where name = 'search_path';

drop function if exists activate_channel_entitlement(org_id_in numeric, channel_family_label_in character varying, quantity_in numeric, flex_in numeric);
drop function if exists activate_system_entitlement(org_id_in numeric, group_label_in character varying, quantity_in numeric);
drop function if exists assign_channel_entitlement(channel_family_label_in character varying, from_org_id_in numeric, to_org_id_in numeric, quantity_in numeric, flex_in numeric);
drop function if exists assign_system_entitlement(group_label_in character varying, from_org_id_in numeric, to_org_id_in numeric, quantity_in numeric);
drop function if exists create_entitlement_group(org_id_in numeric, type_label_in character varying);
drop function if exists entitle_last_modified_servers(customer_id_in numeric, type_label_in character varying, quantity_in numeric);
drop function if exists lookup_entitlement_group(org_id_in numeric, type_label_in character varying);
drop function if exists modify_org_service(org_id_in numeric, service_label_in character varying, enable_in character);
drop function if exists prune_family(customer_id_in numeric, channel_family_id_in numeric, quantity_in numeric, flex_in numeric);
drop function if exists prune_group(group_id_in numeric, quantity_in numeric);
drop function if exists prune_group(group_id_in numeric, quantity_in numeric, update_family_countsyn numeric);
drop function if exists remove_org_entitlements(org_id_in numeric);
drop function if exists remove_server_entitlement(server_id_in numeric, type_label_in character varying, repoll_virt_guests numeric);
drop function if exists repoll_virt_guest_entitlements(server_id_in numeric);
drop function if exists set_customer_enterprise(customer_id_in numeric);
drop function if exists set_customer_monitoring(customer_id_in numeric);
drop function if exists set_customer_nonlinux(customer_id_in numeric);
drop function if exists set_customer_provisioning(customer_id_in numeric);
drop function if exists set_family_count(customer_id_in numeric, channel_family_id_in numeric, quantity_in numeric, flex_in numeric);
drop function if exists set_server_group_count(customer_id_in numeric, group_type_in numeric, quantity_in numeric);
drop function if exists set_server_group_count(customer_id_in numeric, group_type_in numeric, quantity_in numeric, update_family_countsyn numeric);
drop function if exists subscribe_newest_servers(customer_id_in numeric);
drop function if exists unset_customer_enterprise(customer_id_in numeric);
drop function if exists unset_customer_monitoring(customer_id_in numeric);
drop function if exists unset_customer_nonlinux(customer_id_in numeric);
drop function if exists unset_customer_provisioning(customer_id_in numeric);

update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_entitlements')+1) ) where name = 'search_path';
