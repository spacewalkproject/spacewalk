-- oracle equivalent source sha1 1f970f02d67363ec08423b8017be520a2210c1a4
--
-- Copyright (c) 2008--2014 Red Hat, Inc.
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

-- create schema rhn_channel;

--update pg_setting
update pg_settings set setting = 'rhn_channel,' || setting where name = 'search_path';

    create or replace function obtain_read_lock(channel_family_id_in in numeric, org_id_in in numeric)
    returns void as $$
    declare
        read_lock timestamptz;
    begin
        select created into read_lock
          from rhnPrivateChannelFamily
         where channel_family_id = channel_family_id_in and org_id = org_id_in
           for update;
    end$$ language plpgsql;

    -- this "emulates" cursor server_base_subscriptions defined in oracle/rhn_channel.pks
    create or replace function server_base_subscriptions(server_id_in NUMERIC)
    returns boolean as $$
    begin
      return exists(SELECT C.id FROM rhnChannel C, rhnServerChannel SC
		    WHERE C.id = SC.channel_id
		      AND SC.server_id = server_id_in
		      AND C.parent_channel IS NULL);
    end$$ language plpgsql;

    -- this "emulates" cursor server_base_subscriptions defined in oracle/rhn_channel.pks
    create or replace function check_server_subscription(server_id_in NUMERIC, channel_id_in NUMERIC)
    returns boolean as $$
    begin
      return exists(SELECT channel_id FROM rhnServerChannel WHERE server_id = server_id_in AND channel_id = channel_id_in);
    end$$ language plpgsql;


    CREATE OR REPLACE FUNCTION subscribe_server(server_id_in IN NUMERIC, channel_id_in NUMERIC, immediate_in NUMERIC default 1, user_id_in in numeric default null) returns void
    AS $$
    declare
        channel_parent_val      rhnChannel.parent_channel%TYPE;
        parent_subscribed       BOOLEAN;
        server_has_base_chan    BOOLEAN;
        server_already_in_chan  BOOLEAN;
        channel_family_id_val   NUMERIC;
        server_org_id_val       NUMERIC;
        allowed                 numeric;
    BEGIN
        if user_id_in is not null then
            allowed := rhn_channel.user_role_check(channel_id_in, user_id_in, 'subscribe');
        else
            allowed := 1;
        end if;

        if allowed = 0 then
            perform rhn_exception.raise_exception('no_subscribe_permissions');
        end if;


        SELECT parent_channel INTO channel_parent_val FROM rhnChannel WHERE id = channel_id_in;

        IF channel_parent_val IS NOT NULL
        THEN
            -- child channel; if attempting to cross-subscribe a child to the wrong base, silently ignore
            parent_subscribed := rhn_channel.check_server_subscription(server_id_in, channel_parent_val);

            IF NOT parent_subscribed
            THEN
                RETURN;
            END IF;
        ELSE
            -- base channel
            server_has_base_chan := rhn_channel.server_base_subscriptions(server_id_in);

            IF server_has_base_chan
            THEN
                perform rhn_exception.raise_exception('channel_server_one_base');
            END IF;
        END IF;

        server_already_in_chan := rhn_channel.check_server_subscription(server_id_in, channel_id_in);

        IF server_already_in_chan
        THEN
            RETURN;
        END IF;

        channel_family_id_val := rhn_channel.family_for_channel(channel_id_in);
        IF channel_family_id_val IS NULL
        THEN
            perform rhn_exception.raise_exception('channel_subscribe_no_family');
        END IF;

        --
        -- Use the org_id of the server only if the org_id of the channel = NULL.
        -- This is required for subscribing to shared channels.
        --
        SELECT COALESCE(org_id, (SELECT org_id FROM rhnServer WHERE id = server_id_in))
          INTO server_org_id_val
          FROM rhnChannel
         WHERE id = channel_id_in;

        begin
            perform rhn_channel.obtain_read_lock(channel_family_id_val, server_org_id_val);
        exception
            when no_data_found then
                perform rhn_exception.raise_exception('channel_subscribe_no_family');
        end;

        insert into rhnServerHistory (id,server_id,summary,details) (
            select  nextval('rhn_event_id_seq'),
                    server_id_in,
                    'subscribed to channel ' || SUBSTR(c.label, 0, 106),
                    c.label
            from    rhnChannel c
            where   c.id = channel_id_in
        );

        INSERT INTO rhnServerChannel (server_id, channel_id) VALUES (server_id_in, channel_id_in);

        perform queue_server(server_id_in, immediate_in);

        update rhnServer
           set channels_changed = current_timestamp
         where id = server_id_in;
    END$$ language plpgsql;

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

    -- Private function
    create or replace function normalize_server_arch(server_arch_in in varchar)
    returns varchar
    as $$
    declare
        suffix VARCHAR(128) := '-redhat-linux';
    begin
        if server_arch_in is NULL then
            return NULL;
        end if;
        if position('-' IN server_arch_in) > 0
        then
            -- Suffix already present
            return server_arch_in;
        end if;
        return server_arch_in || suffix;
    end$$ language plpgsql;

    --
    -- Raises:
    --   server_arch_not_found
    --   no_subscribe_permissions
    create or replace function base_channel_for_release_arch(
        release_in in varchar,
        server_arch_in in varchar,
        org_id_in in numeric default -1,
        user_id_in in numeric default null
    ) returns numeric as $$
    declare
        server_arch varchar(256) := rhn_channel.normalize_server_arch(server_arch_in);
        server_arch_id numeric;
    begin
        -- Look up the server arch
            select id
              into server_arch_id
              from rhnServerArch
             where label = server_arch;
            if not found then
                perform rhn_exception.raise_exception('server_arch_not_found');
            end if;

        return rhn_channel.base_channel_rel_archid(release_in, server_arch_id,
            org_id_in, user_id_in);
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

    CREATE OR REPLACE FUNCTION clear_subscriptions(server_id_in IN NUMERIC, deleting_server IN NUMERIC default 0) returns void
    AS $$
    declare
        server_channels cursor(server_id_in numeric) for
                select  s.org_id, sc.channel_id, cfm.channel_family_id
                from    rhnServer s,
                        rhnServerChannel sc,
                        rhnChannelFamilyMembers cfm
                where   s.id = server_id_in
                        and s.id = sc.server_id
                        and sc.channel_id = cfm.channel_id
                order by cfm.channel_family_id;
        last_channel_family_id rhnChannelFamilyMembers.channel_family_id%type := -1;
        last_channel_org_id    rhnServer.org_id%type := -1;
    BEGIN
        for channel in server_channels(server_id_in)
        loop
                perform rhn_channel.unsubscribe_server(server_id_in, channel.channel_id, 1, 1, deleting_server);
        end loop;
    END$$ language plpgsql;

    CREATE OR REPLACE FUNCTION unsubscribe_server(server_id_in IN NUMERIC, channel_id_in NUMERIC, immediate_in NUMERIC default 1, unsubscribe_children_in numeric default 0,
                                 deleting_server in numeric default 0) returns void
    AS $$
    declare
        channel_family_id_val   NUMERIC;
        server_org_id_val       NUMERIC;
        server_already_in_chan  BOOLEAN;
        channel_family_is_proxy cursor(channel_family_id_in numeric) for
                select  1
                from    rhnChannelFamily
                where   id = channel_family_id_in
                    and label = 'rhn-proxy';
        channel_family_is_satellite cursor(channel_family_id_in numeric) for
                select  1
                from    rhnChannelFamily
                where   id = channel_family_id_in
                    and label = 'rhn-satellite';
        child record;
    BEGIN
        -- In PostgreSQL recursion with opened cursors is not allowed so we use
        -- FOR IN SELECT form which is ok.
        FOR child IN select  c.id
                from    rhnChannel                      c,
                                rhnServerChannel        sc
                where   1=1
                        and c.parent_channel = channel_id_in
                        and c.id = sc.channel_id
                        and sc.server_id = server_id_in
        LOOP
            if unsubscribe_children_in = 1 then
                perform rhn_channel.unsubscribe_server(server_id_in,
                                                       child.id,
                                                       immediate_in,
                                                       unsubscribe_children_in,
                                                       deleting_server);
            else
                perform rhn_exception.raise_exception('channel_unsubscribe_child_exists');
            end if;
        END LOOP;

        server_already_in_chan := rhn_channel.check_server_subscription(server_id_in, channel_id_in);

        IF NOT server_already_in_chan
        THEN
            RETURN;
        END IF;

   if deleting_server = 0 then
      insert into rhnServerHistory (id,server_id,summary,details) (
          select  nextval('rhn_event_id_seq'),
                server_id_in,
             'unsubscribed from channel ' || SUBSTR(c.label, 0, 106),
             c.label
          from    rhnChannel c
          where   c.id = channel_id_in
      );
   end if;

   DELETE FROM rhnServerChannel WHERE server_id = server_id_in AND channel_id = channel_id_in;

   if deleting_server = 0 then
        perform queue_server(server_id_in, immediate_in);

        update rhnServer
           set channels_changed = current_timestamp
         where id = server_id_in;
   end if;

        channel_family_id_val := rhn_channel.family_for_channel(channel_id_in);
        IF channel_family_id_val IS NULL
        THEN
            perform rhn_exception.raise_exception('channel_unsubscribe_no_family');
        END IF;

        for ignore in channel_family_is_satellite(channel_family_id_val) loop
                delete from rhnSatelliteInfo where server_id = server_id_in;
        end loop;

        for ignore in channel_family_is_proxy(channel_family_id_val) loop
                delete from rhnProxyInfo where server_id = server_id_in;
        end loop;
        SELECT org_id INTO server_org_id_val
          FROM rhnServer
         WHERE id = server_id_in;

    END$$ language plpgsql;

    CREATE OR REPLACE FUNCTION family_for_channel(channel_id_in IN NUMERIC)
    RETURNS NUMERIC
    AS $$
    declare
        channel_family_id_val NUMERIC;
    BEGIN
        SELECT channel_family_id INTO channel_family_id_val
          FROM rhnChannelFamilyMembers
         WHERE channel_id = channel_id_in;

        IF NOT FOUND THEN
          RETURN NULL;
        END IF;

        RETURN channel_family_id_val;
    END$$ language plpgsql;

    create or replace function unsubscribe_server_from_family(server_id_in in numeric,
                                             channel_family_id_in in numeric)
    returns void
    as $$
    begin
        delete
        from    rhnServerChannel rsc
        where   rsc.server_id = server_id_in
            and channel_id in (
                select  rcfm.channel_id
                from    rhnChannelFamilyMembers rcfm
                where   rcfm.channel_family_id = channel_family_id_in);
    end$$ language plpgsql;

    create or replace function get_org_id(channel_id_in in numeric)
    returns numeric
    as $$
    declare
        org_id_out numeric;
    begin
        select org_id into strict org_id_out
            from rhnChannel
            where id = channel_id_in;

            return org_id_out;
    end$$ language plpgsql;

    create or replace function get_cfam_org_access(cfam_id_in in numeric, org_id_in in numeric)
    returns numeric
    as $$
    begin
      if exists(
                        select  1
                        from    rhnOrgChannelFamilyPermissions cfp
                        where   cfp.org_id = org_id_in
      ) then
                return 1;
      else
                return 0;
      end if;
    end$$ language plpgsql;

    create or replace function get_org_access(channel_id_in in numeric, org_id_in in numeric)
    returns integer
    as $$
    begin
        -- the idea: if we get past this query,
        -- the org has access to the channel, else not
        if exists(
        select 1
          from rhnChannelFamilyMembers CFM,
               rhnOrgChannelFamilyPermissions CFP
         where cfp.org_id = org_id_in
           and CFM.channel_family_id = CFP.channel_family_id
           and CFM.channel_id = channel_id_in)
        then
          return 1;
        else
          return 0;
        end if;
    end$$ language plpgsql;

    -- check if a user has a given role, or if such a role is inferrable
    -- returns NULL if OK, error message otherwise
    create or replace function user_role_check_debug(channel_id_in in numeric,
                                   user_id_in in numeric,
                                   role_in in varchar)
    returns varchar
    as $$
    declare
        org_id numeric;
    begin
        org_id := rhn_user.get_org_id(user_id_in);

        -- channel might be shared
        if role_in = 'subscribe' and
           rhn_channel.shared_user_role_check(channel_id_in, user_id_in, role_in) = 1 then
            return NULL;
        end if;

        if role_in = 'manage' and
           COALESCE(rhn_channel.get_org_id(channel_id_in), -1) <> org_id then
               return 'channel_not_owned';
        end if;

        if role_in = 'subscribe' and
           rhn_channel.get_org_access(channel_id_in, org_id) = 0 then
                return 'channel_not_available';
        end if;

        -- channel admins have all roles
        if rhn_user.check_role_implied(user_id_in, 'channel_admin') = 1 then
            return NULL;
        end if;

        -- the subscribe permission is inferred
        -- UNLESS the not_globally_subscribable flag is set
        if role_in = 'subscribe'
        then
            if rhn_channel.org_channel_setting(channel_id_in,
                       org_id,
                       'not_globally_subscribable') = 0 then
                return NULL;
            end if;
        end if;

        -- all other roles (manage right now) are explicitly granted
        if rhn_channel.direct_user_role_check(channel_id_in,
                                              user_id_in, role_in) = 1 then
            return NULL;
        end if;
        return 'direct_permission';
    end$$ language plpgsql;

    -- same as above, but with 1/0 output; useful in views, etc
    create or replace function user_role_check(channel_id_in in numeric, user_id_in in numeric, role_in in varchar)
    returns numeric
    as $$
    begin
        if rhn_channel.user_role_check_debug(channel_id_in,
                                             user_id_in, role_in) is NULL then
            return 1;
        else
            return 0;
        end if;
    end$$ language plpgsql;

    --
    -- For multiorg phase II, this function simply checks to see if the user's
    -- has a trust relationship that includes this channel by id.
    --
    create or replace function shared_user_role_check(channel_id in numeric, user_id in numeric, role in varchar)
    returns numeric
    as $$
    declare
      n numeric;
      oid numeric;
    begin
      oid := rhn_user.get_org_id(user_id);
      select 1 into n
      from rhnSharedChannelView s
      where s.id = channel_id and s.org_trust_id = oid;

      if not found then
        return 0;
      end if;

      return 1;
    end$$ language plpgsql;

    -- same as above, but returns 1 if user_id_in is null
    -- This is useful in queries where user_id is not specified
    create or replace function loose_user_role_check(channel_id_in in numeric, user_id_in in numeric, role_in in varchar)
    returns numeric
    as $$
    begin
        if user_id_in is null then
            return 1;
        end if;
        return rhn_channel.user_role_check(channel_id_in, user_id_in, role_in);
    end$$ language plpgsql;

    -- directly checks the table, no inferred permissions
    create or replace function direct_user_role_check(channel_id_in in numeric, user_id_in in numeric, role_in in varchar)
    returns numeric
    as $$
    declare
        throwaway numeric;
    begin
        -- the idea: if we get past this query, the user has the role, else no
        select 1 into throwaway
          from rhnChannelPermissionRole CPR,
               rhnChannelPermission CP
         where CP.user_id = user_id_in
           and CP.channel_id = channel_id_in
           and CPR.label = role_in
           and CP.role_id = CPR.id;

      if not found then
        return 0;
      end if;

      return 1;
    end$$ language plpgsql;

    -- check if an org has a certain setting
    create or replace function org_channel_setting(channel_id_in in numeric, org_id_in in numeric, setting_in in varchar)
    returns numeric
    as $$
    declare
        throwaway numeric;
    begin
        -- the idea: if we get past this query, the org has the setting
        select 1 into throwaway
          from rhnOrgChannelSettingsType OCST,
               rhnOrgChannelSettings OCS
         where OCS.org_id = org_id_in
           and OCS.channel_id = channel_id_in
           and OCST.label = setting_in
           and OCS.setting_id = OCST.id;

      if not found then
        return 0;
      end if;

      return 1;
    end$$ language plpgsql;

    CREATE OR REPLACE FUNCTION channel_priority(channel_id_in IN numeric)
    RETURNS numeric
    AS $$
    declare
         channel_name varchar(256);
         priority numeric;
         end_of_life_val timestamptz;
         org_id_val numeric;
    BEGIN

        select name, end_of_life, org_id
        into channel_name, end_of_life_val, org_id_val
        from rhnChannel
        where id = channel_id_in;

        if end_of_life_val is not null then
          return -400;
        end if;

        if channel_name like 'Red Hat Enterprise Linux%' or channel_name like 'RHEL%' then
          priority := 1000;
          if channel_name not like '%Beta%' then
            priority := priority + 1000;
          end if;

          priority := priority +
            case
              when channel_name like '%v. 5%' then 600
              when channel_name like '%v. 4%' then 500
              when channel_name like '%v. 3%' then 400
              when channel_name like '%v. 2%' then 300
              when channel_name like '%v. 1%' then 200
              else 0
            end;

          priority := priority +
            case
              when channel_name like 'Red Hat Enterprise Linux (v. 5%' then 60
              when (channel_name like '%AS%' and channel_name not like '%Extras%') then 50
              when (channel_name like '%ES%' and channel_name not like '%Extras%') then 40
              when (channel_name like '%WS%' and channel_name not like '%Extras%') then 30
              when (channel_name like '%Desktop%' and channel_name not like '%Extras%') then 20
              when channel_name like '%Extras%' then 10
              else 0
            end;

          priority := priority +
            case
              when channel_name like '%)' then 5
              else 0
            end;

          priority := priority +
            case
              when channel_name like '%32-bit x86%' then 4
              when channel_name like '%64-bit Intel Itanium%' then 3
              when channel_name like '%64-bit AMD64/Intel EM64T%' then 2
              else 0
            end;
        elsif channel_name like 'Red Hat Desktop%' then
            priority := 900;

            if channel_name not like '%Beta%' then
               priority := priority + 50;
            end if;

          priority := priority +
            case
              when channel_name like '%v. 4%' then 40
              when channel_name like '%v. 3%' then 30
              when channel_name like '%v. 2%' then 20
              when channel_name like '%v. 1%' then 10
              else 0
            end;

          priority := priority +
            case
              when channel_name like '%32-bit x86%' then 4
              when channel_name like '%64-bit Intel Itanium%' then 3
              when channel_name like '%64-bit AMD64/Intel EM64T%' then 2
              else 0
            end;

        elsif org_id_val is not null then
          priority := 600;
        else
          priority := 500;
        end if;

      return -priority;

    end$$ language plpgsql;

    -- this could certainly be optimized to do updates if needs be
    create or replace function refresh_newest_package(channel_id_in in numeric,
                                      caller_in in varchar default '(unknown)',
                                      package_name_id_in in numeric default null)
    returns void
    as $$
    -- procedure refreshes rows for name_id = package_name_id_in or
    -- all rows if package_name_id_in is null
    begin
        delete from rhnChannelNewestPackage
              where channel_id = channel_id_in
                and (package_name_id_in is null
                     or name_id = package_name_id_in);
        insert into rhnChannelNewestPackage
                (channel_id, name_id, evr_id, package_id, package_arch_id)
                (select channel_id,
                        name_id, evr_id,
                        package_id, package_arch_id
                   from rhnChannelNewestPackageView
                  where channel_id = channel_id_in
                    and (package_name_id_in is null
                         or name_id = package_name_id_in)
                );
        insert into rhnChannelNewestPackageAudit (channel_id, caller)
             values (channel_id_in, caller_in);
        update rhnChannel
           set last_modified = greatest(current_timestamp,
                                        last_modified + interval '1 second')
         where id = channel_id_in;
    end$$ language plpgsql;

   create or replace function update_channel ( channel_id_in in numeric, invalidate_ss in numeric default 0,
                              date_to_use in timestamptz default current_timestamp ) returns void
   as $$
   declare
   channel_last_modified timestamptz;
   last_modified_value timestamptz;

   snapshots cursor for
   select  snapshot_id id
   from    rhnSnapshotChannel
   where   channel_id = channel_id_in;

   begin

      select last_modified
      into channel_last_modified
      from rhnChannel
      where id = channel_id_in;

      last_modified_value := date_to_use;

      if last_modified_value <= channel_last_modified then
          last_modified_value := last_modified_value + interval '1 second';
      end if;

      update rhnChannel set last_modified = last_modified_value
      where id = channel_id_in;

      if invalidate_ss = 1 then
        for snapshot in snapshots loop
            update rhnSnapshot
            set invalid = lookup_snapshot_invalid_reason('channel_modified')
            where id = snapshot.id;
        end loop;
      end if;

   end$$ language plpgsql;

   create or replace function update_channels_by_package ( package_id_in in numeric, date_to_use in timestamptz default current_timestamp ) returns void
   as $$
   declare
   channels cursor for
   select channel_id
   from rhnChannelPackage
   where package_id = package_id_in
   order by channel_id;

   begin
      for channel in channels loop
         -- we want to invalidate the snapshot assocated with the channel when we
         -- do this b/c we know we've added or removed or packages
         perform rhn_channel.update_channel ( channel.channel_id, 1, date_to_use );
      end loop;
   end$$ language plpgsql;


   create or replace function update_channels_by_errata ( errata_id_in numeric, date_to_use in timestamptz default current_timestamp ) returns void
   as $$
   declare
   channels cursor for
   select channel_id
   from rhnChannelErrata
   where errata_id = errata_id_in
   order by channel_id;

   begin
      for channel in channels loop
         -- we won't invalidate snapshots, b/c just changing the errata associated with
         -- a channel shouldn't invalidate snapshots
         perform rhn_channel.update_channel ( channel.channel_id, 0, date_to_use );
      end loop;
   end$$ language plpgsql;

   create or replace function update_needed_cache(channel_id_in in numeric) returns void
   as $$
   declare
   server record;
   begin
      -- we intentionaly do a loop here instead of one huge select
      -- b/c we want to break update into smaller transaction to unblock other sessions
      -- querying rhnServerNeededCache
      for server in (
                select sc.server_id as id
                  from rhnServerChannel sc
                 where sc.channel_id = channel_id_in
                 order by id asc
      ) loop
         perform queue_server(server.id, 0); -- NOT IMMEDIATE
      end loop;
   end$$ language plpgsql;

    create or replace function set_comps(channel_id_in in numeric, path_in in varchar, timestamp_in in varchar) returns void
    as $$
    declare
    row record;
    begin
        for row in (
            select relative_filename, last_modified
            from rhnChannelComps
            where channel_id = channel_id_in
            ) loop
            if row.relative_filename = path_in
                and row.last_modified = to_timestamp(timestamp_in, 'YYYYMMDDHH24MISS') then
                return;
            end if;
        end loop;
        delete from rhnChannelComps
        where channel_id = channel_id_in;
        insert into rhnChannelComps (id, channel_id, relative_filename, last_modified, created, modified)
        values (sequence_nextval('rhn_channelcomps_id_seq'), channel_id_in, path_in, to_timestamp(timestamp_in, 'YYYYMMDDHH24MISS'), current_timestamp, current_timestamp);
    end$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_channel')+1) ) where name = 'search_path';
