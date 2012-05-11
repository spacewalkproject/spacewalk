-- oracle equivalent source sha1 27d4ee8093e5bc67d2356f9544a837239771cdae

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_org,' || setting where name = 'search_path';


create or replace function delete_org (
        org_id_in in numeric
    ) returns void
    as
    $$
    declare
        users cursor for
        select id
        from web_contact
        where org_id = org_id_in;

        servers cursor (org_id_in numeric) for
        select  id
        from    rhnServer
        where   org_id = org_id_in;

        config_channels cursor for
        select id
        from rhnConfigChannel
        where org_id = org_id_in;

        custom_channels cursor for
        select  id
        from    rhnChannel
        where   org_id = org_id_in;

        errata cursor for
        select  id
        from    rhnErrata
        where   org_id = org_id_in;

    begin

        if org_id_in = 1 then
            perform rhn_exception.raise_exception('cannot_delete_base_org');
        end if;

        -- Delete all users.
        for u in users loop
            perform rhn_org.delete_user(u.id, 1);
        end loop;

        -- Delete all servers.
        for s in servers(org_id_in) loop
            perform delete_server(s.id);
        end loop;

        -- Delete all config channels.
        for c in config_channels loop
            perform rhn_config.delete_channel(c.id);
        end loop;

        -- Delete all custom channels.
        for cc in custom_channels loop
          delete from rhnServerChannel where channel_id = cc.id;
          delete from rhnServerProfilePackage where server_profile_id in (
            select id from rhnServerProfile where base_channel = cc.id
          );
          delete from rhnServerProfile where base_channel = cc.id;
        end loop;

        -- Delete all errata packages 
        for e in errata loop
            delete from rhnErrataPackage where errata_id = e.id;
        end loop;

        -- Give the org's entitlements back to the main org.
        perform rhn_entitlements.remove_org_entitlements(org_id_in);

        -- Clean up tables where we don't have a cascading delete.
        delete from rhnChannel where org_id = org_id_in;
        delete from rhnDailySummaryQueue where org_id = org_id_in;
        delete from rhnFileList where org_id = org_id_in;
        delete from rhnServerGroup where org_id = org_id_in;
        delete from rhn_check_suites where customer_id = org_id_in;
        delete from rhn_command_target where customer_id = org_id_in;
        delete from rhn_contact_groups where customer_id = org_id_in;
        delete from rhn_notification_formats where customer_id = org_id_in;
        delete from rhn_probe where customer_id = org_id_in;
        delete from rhn_redirects where customer_id = org_id_in;
        delete from rhn_sat_cluster where customer_id = org_id_in;
        delete from rhn_schedules where customer_id = org_id_in;
        delete from rhnContentSource where org_id = org_id_in;

        -- Delete the org.
        delete from web_customer where id = org_id_in;

    end;
    $$
    language plpgsql;


-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_org')+1) ) where name = 'search_path';
