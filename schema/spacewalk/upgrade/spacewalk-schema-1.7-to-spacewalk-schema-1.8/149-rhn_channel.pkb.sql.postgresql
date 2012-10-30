-- oracle equivalent source sha1 b0c8a29f5f1f28d2308ccaf6b52a4e54c3999e7c

--update pg_setting
update pg_settings set setting = 'rhn_channel,' || setting where name = 'search_path';

    create or replace function guess_server_base(
        server_id_in in numeric
    ) RETURNS numeric as $$
    declare
        server_cursor cursor for
            select s.server_arch_id, s.release, s.org_id
              from rhnServer s
             where s.id = server_id_in;
    -- Cursor that fetches all the possible base channels for a
    -- (server_arch_id, release, org_id) combination
        base_channel_cursor cursor(
                release_in varchar,
                server_arch_id_in numeric,
                org_id_in numeric
        ) for
                select distinct c.*
                from    rhnOrgDistChannelMap                       odcm,
                                rhnServerChannelArchCompat      scac,
                                rhnChannel                                      c
                where   c.parent_channel is null
                        and c.id = odcm.channel_id
                        and c.channel_arch_id = odcm.channel_arch_id
                        and odcm.release = release_in
                        and odcm.for_org_id = org_id_in
                        and scac.server_arch_id = server_arch_id_in
                        and scac.channel_arch_id = c.channel_arch_id;

    begin
        for s in server_cursor loop
            for channel in base_channel_cursor(s.release,
                s.server_arch_id, s.org_id)
            loop
                return channel.id;
            end loop;
        end loop;
        -- Server not found, or no base channel applies to it
        return null;
    end$$ language plpgsql;

    create or replace function base_channel_rel_archid(
        release_in in varchar,
        server_arch_id_in in numeric,
        org_id_in in numeric default -1,
        user_id_in in numeric default null
    ) returns numeric as $$
    declare
        denied_channel_id numeric := null;
        valid_org_id numeric := org_id_in;
        valid_user_id numeric := user_id_in;
        channel_subscribable numeric;
    -- Cursor that fetches all the possible base channels for a
    -- (server_arch_id, release, org_id) combination
        base_channel_cursor cursor(
                release_in varchar,
                server_arch_id_in numeric,
                org_id_in numeric
        ) for
                select distinct c.*
                from    rhnOrgDistChannelMap                       odcm,
                                rhnServerChannelArchCompat      scac,
                                rhnChannel                                      c
                where   c.parent_channel is null
                        and c.id = odcm.channel_id
                        and c.channel_arch_id = odcm.channel_arch_id
                        and odcm.release = release_in
                        and odcm.for_org_id = org_id_in
                        and scac.server_arch_id = server_arch_id_in
                        and scac.channel_arch_id = c.channel_arch_id;

    begin
        if org_id_in = -1 and user_id_in is not null then
            -- Get the org id from the user id

                select org_id
                  into valid_org_id
                  from web_contact
                 where id = user_id_in;

                if not found then
                    -- User doesn't exist
                    -- XXX Only list public stuff for now
                    valid_user_id := null;
                    valid_org_id := -1;
                end if;
        end if;

        for c in base_channel_cursor(release_in, server_arch_id_in, valid_org_id)
        loop
            -- This row is a possible match
            if valid_user_id is null then
                -- User ID not specified, so no user to channel permissions to
                -- check
                return c.id;
            end if;

            -- Check user to channel permissions
            select rhn_channel.loose_user_role_check(c.id, user_id_in, 'subscribe')
              into channel_subscribable;

            if channel_subscribable = 1 then
                return c.id;
            end if;

            -- Base channel exists, but is not subscribable; keep trying
            denied_channel_id := c.id;
        end loop;

        if denied_channel_id is not null then
            perform rhn_exception.raise_exception('no_subscribe_permissions');
        end if;
        -- No base channel applies
        return NULL;
    end$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_channel')+1) ) where name = 'search_path';
