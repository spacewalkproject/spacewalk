-- oracle equivalent source sha1 16f4e58f383e0a61bf752b1a99a31a86780659dd
--
-- Copyright (c) 2011 Red Hat, Inc.

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_entitlements,' || setting where name = 'search_path';

    create or replace function set_customer_enterprise (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'enterprise', 'Y');
    end$$
language plpgsql;

    create or replace function set_customer_provisioning (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'provisioning', 'Y');
    end$$
language plpgsql;

    create or replace function set_customer_monitoring (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'monitoring', 'Y');
    end$$
language plpgsql;

    create or replace function set_customer_nonlinux (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'nonlinux', 'Y');
    end$$
language plpgsql;

    create or replace function unset_customer_enterprise (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'enterprise', 'N');
    end$$
language plpgsql;

    create or replace function unset_customer_provisioning (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'provisioning', 'N');
    end$$
language plpgsql;

    create or replace function unset_customer_monitoring (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'monitoring', 'N');
    end$$
language plpgsql;

    create or replace function unset_customer_nonlinux (
        customer_id_in in numeric
    ) returns void
as $$
    begin
        perform rhn_entitlements.modify_org_service(customer_id_in, 'nonlinux', 'N');
    end$$
language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_entitlements')+1) ) where name = 'search_path';
