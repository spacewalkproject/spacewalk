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
PACKAGE BODY rhn_channel
IS
        body_version varchar2(100) := '';

    -- Cursor that fetches all the possible base channels for a
    -- (server_arch_id, release, org_id) combination
        cursor  base_channel_cursor(
                release_in in varchar2,
                server_arch_id_in in number,
                org_id_in in number
        ) return rhnChannel%ROWTYPE is
                select distinct c.*
                from    rhnDistChannelMap                       dcm,
                                rhnServerChannelArchCompat      scac,
                                rhnChannel                                      c,
                                rhnChannelPermissions           cp
                where   cp.org_id = org_id_in
                        and cp.channel_id = c.id
                        and c.parent_channel is null
                        and c.id = dcm.channel_id
                        and c.channel_arch_id = dcm.channel_arch_id
                        and dcm.release = release_in
                        and scac.server_arch_id = server_arch_id_in
                        and scac.channel_arch_id = c.channel_arch_id;

    procedure obtain_read_lock(channel_family_id_in in number, org_id_in in number)
    is
        read_lock date;

    begin
        select created into read_lock
          from rhnPrivateChannelFamily
         where channel_family_id = channel_family_id_in and org_id = org_id_in
           for update;
    end obtain_read_lock;

    PROCEDURE subscribe_server(server_id_in IN NUMBER, channel_id_in NUMBER, immediate_in NUMBER := 1, user_id_in in number := null, recalcfamily_in number := 1)
    IS
        channel_parent_val      rhnChannel.parent_channel%TYPE;
        parent_subscribed       BOOLEAN;
        server_has_base_chan    BOOLEAN;
        server_already_in_chan  BOOLEAN;
        channel_family_id_val   NUMBER;
        server_org_id_val       NUMBER;
        available_subscriptions NUMBER;
        available_fve_subs      NUMBER;
        consenting_user         NUMBER;
        allowed                 number := 0;
        is_fve                  CHAR(1) := 'N';
    BEGIN
        if user_id_in is not null then
            allowed := rhn_channel.user_role_check(channel_id_in, user_id_in, 'subscribe');
        else
            allowed := 1;
        end if;

        if allowed = 0 then
            rhn_exception.raise_exception('no_subscribe_permissions');
        end if;


        SELECT parent_channel INTO channel_parent_val FROM rhnChannel WHERE id = channel_id_in;

        IF channel_parent_val IS NOT NULL
        THEN    
            -- child channel; if attempting to cross-subscribe a child to the wrong base, silently ignore
            parent_subscribed := FALSE;    

            FOR check_subscription IN check_server_subscription(server_id_in, channel_parent_val)
            LOOP
                parent_subscribed := TRUE;
            END LOOP check_subscription;
        
            IF NOT parent_subscribed
            THEN
                RETURN;
            END IF;
        ELSE
            -- base channel
            server_has_base_chan := FALSE;
            FOR base IN server_base_subscriptions(server_id_in)
            LOOP
                server_has_base_chan := TRUE;
            END LOOP base;
            
            IF server_has_base_chan
            THEN
                rhn_exception.raise_exception('channel_server_one_base');
            END IF;
        END IF;
    
        FOR check_subscription IN check_server_subscription(server_id_in, channel_id_in)
        LOOP
            server_already_in_chan := TRUE;
        END LOOP check_subscription;
    
        IF server_already_in_chan
        THEN
            RETURN;
        END IF;
        
        channel_family_id_val := rhn_channel.family_for_channel(channel_id_in);
        IF channel_family_id_val IS NULL
        THEN
            rhn_exception.raise_exception('channel_subscribe_no_family');
        END IF;

        --
        -- Use the org_id of the server only if the org_id of the channel = NULL.
        -- This is required for subscribing to shared channels.
        --
        SELECT NVL(org_id, (SELECT org_id FROM rhnServer WHERE id = server_id_in))
          INTO server_org_id_val
          FROM rhnChannel
         WHERE id = channel_id_in;
         
        begin
            obtain_read_lock(channel_family_id_val, server_org_id_val);
        exception
            when no_data_found then
                rhn_exception.raise_exception('channel_family_no_subscriptions');
        end;

        available_subscriptions := rhn_channel.available_family_subscriptions(channel_family_id_val, server_org_id_val);
        available_fve_subs := rhn_channel.available_fve_family_subs(channel_family_id_val, server_org_id_val);

        IF available_subscriptions IS NULL OR
            available_subscriptions > 0 or
            can_server_consume_virt_channl(server_id_in, channel_family_id_val) = 1 OR
            (available_fve_subs > 0 AND can_server_consume_fve(server_id_in) = 1)
        THEN
            if can_server_consume_virt_channl(server_id_in, channel_family_id_val) = 0 AND available_fve_subs > 0 AND can_server_consume_fve(server_id_in) = 1 THEN
                is_fve := 'Y';
            END IF;
            insert into rhnServerHistory (id,server_id,summary,details) (
                select  rhn_event_id_seq.nextval,
                        server_id_in,
                        'subscribed to channel ' || SUBSTR(c.label, 0, 106),
                        c.label
                from    rhnChannel c
                where   c.id = channel_id_in
            );
            UPDATE rhnServer SET channels_changed = sysdate WHERE id = server_id_in;
            INSERT INTO rhnServerChannel (server_id, channel_id, is_fve) VALUES (server_id_in, channel_id_in, is_fve);
			IF recalcfamily_in > 0
			THEN
                rhn_channel.update_family_counts(channel_family_id_val, server_org_id_val);
			END IF;
            queue_server(server_id_in, immediate_in);
        ELSE
            rhn_exception.raise_exception('channel_family_no_subscriptions');
        END IF;
            
    END subscribe_server;



    FUNCTION can_convert_to_fve(server_id_in IN NUMBER, channel_family_id_val IN NUMBER)
    RETURN NUMBER
    IS
        CURSOR fve_convertible_entries IS
        select 1  from
            rhnServerFveCapable cap
          where cap.server_id = server_id_in
                AND cap.channel_family_id = channel_family_id_val;
    BEGIN
        FOR entry IN fve_convertible_entries LOOP
            return 1;
        END LOOP;
        RETURN 0;
    END can_convert_to_fve;



    -- Converts server channel_family to use a flex entitlement
    PROCEDURE convert_to_fve(server_id_in IN NUMBER, channel_family_id_val IN NUMBER)
    IS
        available_fve_subs      NUMBER;
        server_org_id_val       NUMBER;        
    BEGIN

        --
        -- Use the org_id of the server only if the org_id of the channel = NULL.
        -- This is required for subscribing to shared channels.
        --
        SELECT org_id
          INTO server_org_id_val
          FROM rhnServer
         WHERE id = server_id_in;
         
        begin
            obtain_read_lock(channel_family_id_val, server_org_id_val);
        exception
            when no_data_found then
                rhn_exception.raise_exception('channel_family_no_subscriptions');
        end;
        IF (can_convert_to_fve(server_id_in, channel_family_id_val ) = 0) 
            THEN
                rhn_exception.raise_exception('server_cannot_convert_to_flex');
        END IF;

        available_fve_subs := rhn_channel.available_fve_family_subs(channel_family_id_val, server_org_id_val);

        IF (available_fve_subs > 0)
        THEN
        
            insert into rhnServerHistory (id,server_id,summary,details) (
                select  rhn_event_id_seq.nextval,
                        server_id_in,
                        'converted to flex entitlement' || SUBSTR(cf.label, 0, 99),
                        cf.label
                from    rhnChannelFamily cf
                where   cf.id = channel_family_id_val
            );

            UPDATE rhnServerChannel sc set sc.is_fve = 'Y' 
                           where sc.server_id = server_id_in and  
                                 sc.channel_id in 
                                    (select cfm.channel_id from rhnChannelFamilyMembers cfm
                                                where cfm.CHANNEL_FAMILY_ID = channel_family_id_val);
            
            rhn_channel.update_family_counts(channel_family_id_val, server_org_id_val);
        ELSE
            rhn_exception.raise_exception('not_enough_flex_entitlements');
        END IF;
            
    END convert_to_fve;    
    
    function can_server_consume_virt_channl(
        server_id_in in number,
        family_id_in in number )
    return number
    is

        cursor server_virt_families is
            select vi.virtual_system_id, cfvsl.channel_family_id
            from
                rhnChannelFamilyVirtSubLevel cfvsl,
                rhnSGTypeVirtSubLevel sgtvsl,
                rhnVirtualInstance vi
            where
                vi.virtual_system_id = server_id_in 
                and sgtvsl.virt_sub_level_id = cfvsl.virt_sub_level_id
                and cfvsl.channel_family_id = family_id_in
                and exists (
                    select 1
                    from rhnServerEntitlementView sev
                    where vi.host_system_id = sev.server_id
                    and sev.server_group_type_id = sgtvsl.server_group_type_id );
    begin

        for server_virt_family in server_virt_families loop
            return 1;
        end loop;

        return 0;

    end;

    FUNCTION can_server_consume_fve(server_id_in IN NUMBER)
    RETURN NUMBER
    IS
        CURSOR vi_entries IS
            SELECT 1
              FROM rhnVirtualInstance vi
             WHERE vi.virtual_system_id = server_id_in
             and not exists(select server_id from rhnServerChannel sc where 
                            sc.server_id = vi.virtual_system_id 
                            and  sc.is_fve='Y');
        vi_count NUMBER;

    BEGIN
        FOR vi_entry IN VI_ENTRIES LOOP
            return 1;
        END LOOP;
        RETURN 0;
    END;

    function guess_server_base(
        server_id_in in number
    ) RETURN number is
        cursor server_cursor is
            select s.server_arch_id, s.release, s.org_id
              from rhnServer s
             where s.id = server_id_in;
    begin
        for s in server_cursor loop
            for channel in base_channel_cursor(s.release,
                s.server_arch_id, s.org_id) 
            loop
                return channel.id;
            end loop base_channel_cursor;
        end loop server_cursor;
        -- Server not found, or no base channel applies to it
        return null;
    end;

    -- Private function
    function normalize_server_arch(server_arch_in in varchar2)
    return varchar2
    deterministic
    is
        suffix VARCHAR2(128) := '-redhat-linux';
        suffix_len NUMBER := length(suffix);
    begin
        if server_arch_in is NULL then
            return NULL;
        end if;
        if instr(server_arch_in, '-') > 0
        then
            -- Suffix already present
            return server_arch_in;
        end if;
        return server_arch_in || suffix;
    end normalize_server_arch;

    --
    --
    -- Raises: 
    --   server_arch_not_found
    --   no_subscribe_permissions
    function base_channel_for_release_arch(
        release_in in varchar2,
        server_arch_in in varchar2,
        org_id_in in number := -1,
        user_id_in in number := null
    ) return number is
        server_arch varchar2(256) := normalize_server_arch(server_arch_in);
        server_arch_id number;
    begin
        -- Look up the server arch
        begin
            select id
              into server_arch_id
              from rhnServerArch
             where label = server_arch;
        exception
            when no_data_found then
                rhn_exception.raise_exception('server_arch_not_found');
        end;
        return base_channel_rel_archid(release_in, server_arch_id,
            org_id_in, user_id_in);
    end base_channel_for_release_arch;

    function base_channel_rel_archid(
        release_in in varchar2,
        server_arch_id_in in number,
        org_id_in in number := -1,
        user_id_in in number := null
    ) return number is
        denied_channel_id number := null;
        valid_org_id number := org_id_in;
        valid_user_id number := user_id_in;
        channel_subscribable number;
    begin
        if org_id_in = -1 and user_id_in is not null then
            -- Get the org id from the user id
            begin
                select org_id
                  into valid_org_id
                  from web_contact
                 where id = user_id_in;
            exception
                when no_data_found then
                    -- User doesn't exist
                    -- XXX Only list public stuff for now
                    valid_user_id := null;
                    valid_org_id := -1;
            end;
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
            select loose_user_role_check(c.id, user_id_in, 'subscribe')
              into channel_subscribable
              from dual;

            if channel_subscribable = 1 then
                return c.id;
            end if;
                
            -- Base channel exists, but is not subscribable; keep trying
            denied_channel_id := c.id;
        end loop base_channel_fetch;
        
        if denied_channel_id is not null then
            rhn_exception.raise_exception('no_subscribe_permissions');
        end if;
        -- No base channel applies
        return NULL;
    end base_channel_rel_archid;

    PROCEDURE clear_subscriptions(server_id_in IN NUMBER, deleting_server IN NUMBER := 0,
                                update_family_countsYN IN NUMBER := 1)
    IS
        cursor server_channels(server_id_in in number) is
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
                unsubscribe_server(server_id_in, channel.channel_id, 1, 1, deleting_server, 0);
                if update_family_countsYN
                    and channel.channel_family_id != last_channel_family_id then
                    -- update family counts only once
                    -- after all channels with same family has been fetched
                    update_family_counts(last_channel_family_id, last_channel_org_id);
                    last_channel_family_id := channel.channel_family_id;
                    last_channel_org_id    := channel.org_id;
                end if;
        end loop channel;
        if update_family_countsYN and last_channel_family_id != -1 then
            -- update the last family fetched
            update_family_counts(last_channel_family_id, channel.org_id);
        end if;
    END clear_subscriptions;

    PROCEDURE unsubscribe_server(server_id_in IN NUMBER, channel_id_in NUMBER, immediate_in NUMBER := 1, unsubscribe_children_in number := 0,
                                 deleting_server IN NUMBER := 0,
                                 update_family_countsYN IN NUMBER := 1)
    IS
        channel_family_id_val   NUMBER;
        server_org_id_val       NUMBER;
        available_subscriptions NUMBER; 
        server_already_in_chan  BOOLEAN;
        cursor  channel_family_is_proxy(channel_family_id_in in number) is
                select  1
                from    rhnChannelFamily
                where   id = channel_family_id_in
                    and label = 'rhn-proxy';
        cursor  channel_family_is_satellite(channel_family_id_in in number) is
                select  1
                from    rhnChannelFamily
                where   id = channel_family_id_in
                    and label = 'rhn-satellite';
        -- this is *EXACTLY* like check_server_parent_membership, but if we recurse
        -- with the package-level one, we get a "cursor already open", so we need a
        -- copy on our call stack instead.  GROAN.
        cursor local_chk_server_parent_memb (
                        server_id_in number,
                        channel_id_in number ) is
                select  c.id
                from    rhnChannel                      c,
                                rhnServerChannel        sc
                where   1=1
                        and c.parent_channel = channel_id_in
                        and c.id = sc.channel_id
                        and sc.server_id = server_id_in;
    BEGIN
        FOR child IN local_chk_server_parent_memb(server_id_in, channel_id_in)
        LOOP
            if unsubscribe_children_in = 1 then
                unsubscribe_server(server_id_in => server_id_in,
                                                                channel_id_in => child.id,
                                                                immediate_in => immediate_in,
                                                                unsubscribe_children_in => unsubscribe_children_in,
                        deleting_server => deleting_server,
                        update_family_countsYN => update_family_countsYN);
            else
                rhn_exception.raise_exception('channel_unsubscribe_child_exists');
            end if;
        END LOOP child;
        
        server_already_in_chan := FALSE;
    
        FOR check_subscription IN check_server_subscription(server_id_in, channel_id_in)
        LOOP
            server_already_in_chan := TRUE;
        END LOOP check_subscription;
    
        IF NOT server_already_in_chan
        THEN
            RETURN;
        END IF;
        
   if deleting_server = 0 then 

      insert into rhnServerHistory (id,server_id,summary,details) (
          select  rhn_event_id_seq.nextval,
                server_id_in,
             'unsubscribed from channel ' || SUBSTR(c.label, 0, 106),
             c.label
          from    rhnChannel c
          where   c.id = channel_id_in
      );

        UPDATE rhnServer SET channels_changed = sysdate WHERE id = server_id_in;
   end if;
        
   DELETE FROM rhnServerChannel WHERE server_id = server_id_in AND channel_id = channel_id_in;

   if deleting_server = 0 then 
        queue_server(server_id_in, immediate_in);
   end if;

        channel_family_id_val := rhn_channel.family_for_channel(channel_id_in);
        IF channel_family_id_val IS NULL
        THEN
            rhn_exception.raise_exception('channel_unsubscribe_no_family');
        END IF;

        for ignore in channel_family_is_satellite(channel_family_id_val) loop
                delete from rhnSatelliteInfo where server_id = server_id_in;
                delete from rhnSatelliteChannelFamily where server_id = server_id_in;
        end loop;

        for ignore in channel_family_is_proxy(channel_family_id_val) loop
                delete from rhnProxyInfo where server_id = server_id_in;
        end loop;
        SELECT org_id INTO server_org_id_val
          FROM rhnServer
         WHERE id = server_id_in;
         
        if update_family_countsYN = 1 then
            rhn_channel.update_family_counts(channel_family_id_val, server_org_id_val);
        end if;
    END unsubscribe_server;


    FUNCTION family_for_channel(channel_id_in IN NUMBER)
    RETURN NUMBER
    IS
        channel_family_id_val NUMBER;
    BEGIN
        SELECT channel_family_id INTO channel_family_id_val
          FROM rhnChannelFamilyMembers
         WHERE channel_id = channel_id_in;
         
        RETURN channel_family_id_val;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END family_for_channel;

    FUNCTION available_family_subscriptions(channel_family_id_in IN NUMBER, org_id_in IN NUMBER)
    RETURN NUMBER
    IS
        cfp channel_family_perm_cursor%ROWTYPE;
        current_members_val NUMBER;
        max_members_val     NUMBER;
        found               NUMBER;
    BEGIN
        IF NOT channel_family_perm_cursor%ISOPEN
        THEN
            OPEN channel_family_perm_cursor(channel_family_id_in, org_id_in);
        END IF;

        FETCH channel_family_perm_cursor INTO cfp;
        
        WHILE channel_family_perm_cursor%FOUND
        LOOP
            found := 1;
            
            current_members_val := cfp.current_members;
            max_members_val := cfp.max_members;
            
            FETCH channel_family_perm_cursor INTO cfp;
        END LOOP;

        IF channel_family_perm_cursor%ISOPEN
        THEN
            CLOSE channel_family_perm_cursor;
        END IF;

        -- not found: either the channel fam doesn't have an entry in cfp, or the org doesn't have access to it.
        -- either way, there are no available subscriptions
        
        IF found IS NULL
        THEN
            RETURN 0;
        END IF;

        -- null max members?  in that case, pass it on; NULL means infinite                     
        IF max_members_val IS NULL
        THEN
            RETURN NULL;
        END IF;

        -- otherwise, return the delta  
        RETURN max_members_val - current_members_val;                   
    END available_family_subscriptions;

    FUNCTION available_fve_family_subs(channel_family_id_in IN NUMBER, org_id_in IN NUMBER)
    RETURN NUMBER
    IS
        cfp channel_family_perm_cursor%ROWTYPE;
        fve_current_members_val NUMBER;
        fve_max_members_val     NUMBER;
        found               NUMBER;

    BEGIN
        IF NOT channel_family_perm_cursor%ISOPEN THEN
            OPEN channel_family_perm_cursor(channel_family_id_in, org_id_in);
        END IF;

        FETCH channel_family_perm_cursor INTO cfp;

        WHILE channel_family_perm_cursor%FOUND LOOP
            found := 1;
            fve_current_members_val := cfp.fve_current_members;
            fve_max_members_val := cfp.fve_max_members;
            FETCH channel_family_perm_cursor INTO cfp;
        END LOOP;

        IF channel_family_perm_cursor%ISOPEN THEN
            CLOSE channel_family_perm_cursor;
        END IF;

        IF found IS NULL THEN
            RETURN 0;
        END IF;

        IF fve_max_members_val IS NULL THEN
            RETURN NULL;
        END IF;

        RETURN fve_max_members_val - fve_current_members_val;

    END available_fve_family_subs;

    
    -- *******************************************************************
    -- FUNCTION: channel_family_current_members
    -- Calculates and returns the actual count of systems consuming
    --   physical channel subscriptions.
    -- Called by: update_family_counts 
    --            rhn_entitlements.repoll_virt_guest_entitlements
    -- *******************************************************************
    function channel_family_current_members(channel_family_id_in IN NUMBER,
                                            org_id_in IN NUMBER)
    return number
    is
        current_members_count number := 0;
    begin
        select  count(distinct server_id)
        into    current_members_count
          from  rhnChannelFamilyServerPhysical cfsp
         where  cfsp.channel_family_id = channel_family_id_in
           and  cfsp.customer_id = org_id_in;
        return current_members_count;
    end;        


    function cfam_curr_fve_members(
        channel_family_id_in IN NUMBER,
        org_id_in IN NUMBER)
    return number
    is
        current_members_count number := 0;

    begin
        select count(sc.server_id)
          into current_members_count
          from rhnServerChannel sc,
               rhnChannelFamilyMembers cfm,
               rhnServer s
         where s.org_id = org_id_in
           and s.id = sc.server_id
           and cfm.channel_family_id = channel_family_id_in
           and cfm.channel_id = sc.channel_id
           and exists (
                select 1
                  from rhnChannelFamilyServerFve cfsp
                 where cfsp.CHANNEL_FAMILY_ID = channel_family_id_in
                   and cfsp.server_id = s.id
                );

        return current_members_count;
    end;
    PROCEDURE update_family_counts(channel_family_id_in IN NUMBER, 
                                   org_id_in IN NUMBER)
    IS
    BEGIN
        update rhnPrivateChannelFamily
           set current_members = ( channel_family_current_members(channel_family_id_in, org_id_in)),
               fve_current_members = ( cfam_curr_fve_members(channel_family_id_in, org_id_in))
         where org_id = org_id_in
           and channel_family_id = channel_family_id_in;
    END update_family_counts;
    
    PROCEDURE update_group_family_counts(group_label_in IN VARCHAR2,
                                   org_id_in IN NUMBER)
    IS
    BEGIN
        FOR i IN (
                SELECT DISTINCT CFM.channel_family_id, SG.org_id
                 FROM rhnChannelFamilyMembers CFM
                 JOIN rhnServerChannel SC
                   ON SC.channel_id = CFM.channel_id
                 JOIN rhnServerGroupMembers SGM
                   ON SC.server_id = SGM.server_id
                 JOIN rhnServerGroup SG
                   ON SGM.server_group_id = SG.id
                 JOIN rhnServerGroupType SGT
                   ON SG.group_type = SGT.id
                WHERE SGT.label = group_label_in
                  AND SG.org_id = org_id_in
                  AND SGT.is_base = 'Y'
        ) LOOP
            rhn_channel.update_family_counts(i.channel_family_id, i.org_id);
        END LOOP;
    END update_group_family_counts;

    FUNCTION available_chan_subscriptions(channel_id_in IN NUMBER, 
                                          org_id_in IN NUMBER)
    RETURN NUMBER
    IS
            channel_family_id_val NUMBER;
    BEGIN
        SELECT channel_family_id INTO channel_family_id_val
            FROM rhnChannelFamilyMembers
            WHERE channel_id = channel_id_in;
         
            RETURN rhn_channel.available_family_subscriptions(
                           channel_family_id_val, org_id_in);
    END available_chan_subscriptions;

	FUNCTION available_fve_chan_subs(channel_id_in IN NUMBER,
                                          org_id_in IN NUMBER)
    RETURN NUMBER
    IS
        channel_family_id_val NUMBER;

    BEGIN
        SELECT channel_family_id INTO channel_family_id_val
          FROM rhnChannelFamilyMembers
         WHERE channel_id = channel_id_in;

        RETURN rhn_channel.available_fve_family_subs( channel_family_id_val, org_id_in);
    END available_fve_chan_subs;

    procedure unsubscribe_server_from_family(server_id_in in number, 
                                             channel_family_id_in in number)
    is
    begin
        delete
        from    rhnServerChannel rsc
        where   rsc.server_id = server_id_in
            and channel_id in (
                select  rcfm.channel_id
                from    rhnChannelFamilyMembers rcfm
                where   rcfm.channel_family_id = channel_family_id_in);
    end;

    function get_org_id(channel_id_in in number)
    return number
    is
        org_id_out number;
    begin
        select org_id into org_id_out
            from rhnChannel
            where id = channel_id_in;
         
            return org_id_out;
    end get_org_id;
    
    function get_cfam_org_access(cfam_id_in in number, org_id_in in number)
    return number
    is
        cursor  families is
                        select  1
                        from    rhnOrgChannelFamilyPermissions cfp
                        where   cfp.org_id = org_id_in;
    begin
                -- the idea: if we get past this query, 
        -- the user has the role, else catch the exception and return 0
                for family in families loop
                return 1;
                end loop;
                return 0;
    end;

    function get_org_access(channel_id_in in number, org_id_in in number)
    return number
    is
        throwaway number;
    begin
        -- the idea: if we get past this query, 
        -- the org has access to the channel, else catch the exception and return 0
        select distinct 1 into throwaway
          from rhnChannelFamilyMembers CFM,
               rhnOrgChannelFamilyPermissions CFP
         where cfp.org_id = org_id_in
           and CFM.channel_family_id = CFP.channel_family_id
           and CFM.channel_id = channel_id_in
           and (CFP.max_members > 0 or CFP.max_members is null or CFP.org_id = 1);
           
        return 1;
        exception
            when no_data_found
            then
            return 0;
    end;
    
    -- check if a user has a given role, or if such a role is inferrable
    function user_role_check_debug(channel_id_in in number, 
                                   user_id_in in number, 
                                   role_in in varchar2, 
                                   reason_out out varchar2)
    return number
    is
        org_id number;
    begin
        org_id := rhn_user.get_org_id(user_id_in);

        -- channel might be shared
        if role_in = 'subscribe' and
           rhn_channel.shared_user_role_check(channel_id_in, user_id_in, role_in) = 1 then
            return 1;
        end if;
        
        if role_in = 'manage' and 
           NVL(rhn_channel.get_org_id(channel_id_in), -1) <> org_id then
                reason_out := 'channel_not_owned';
               return 0;
            end if;
        
        if role_in = 'subscribe' and 
           rhn_channel.get_org_access(channel_id_in, org_id) = 0 then
                reason_out := 'channel_not_available';
                return 0;
            end if;
        
        -- channel admins have all roles
        if rhn_user.check_role_implied(user_id_in, 'channel_admin') = 1 then
            reason_out := 'channel_admin';
            return 1;
            end if;

        -- the subscribe permission is inferred 
    -- UNLESS the not_globally_subscribable flag is set 
        if role_in = 'subscribe'
        then
            if rhn_channel.org_channel_setting(channel_id_in, 
                       org_id,
                       'not_globally_subscribable') = 0 then
                reason_out := 'globally_subscribable';
                    return 1;
            end if;
        end if;
        
        -- all other roles (manage right now) are explicitly granted    
        reason_out := 'direct_permission';
        return rhn_channel.direct_user_role_check(channel_id_in, 
                                              user_id_in, role_in);
    end;
    
    -- same as above, but with no OUT param; useful in views, etc
    function user_role_check(channel_id_in in number, user_id_in in number, role_in in varchar2)
    return number
    is
        throwaway varchar2(256);
    begin
        return rhn_channel.user_role_check_debug(channel_id_in, user_id_in, role_in, throwaway);
    end;

    --
    -- For multiorg phase II, this function simply checks to see if the user's
    -- has a trust relationship that includes this channel by id.
    --
    function shared_user_role_check(channel_id in number, user_id in number, role in varchar2)
    return number
    is
      n number;
      oid number;
    begin
      oid := rhn_user.get_org_id(user_id);
      select 1 into n
      from rhnSharedChannelView s
      where s.id = channel_id and s.org_trust_id = oid;
      return 1;
      exception
        when no_data_found then
          return 0;
    end;

    -- same as above, but returns 1 if user_id_in is null
    -- This is useful in queries where user_id is not specified
    function loose_user_role_check(channel_id_in in number, user_id_in in number, role_in in varchar2)
    return number
    is
    begin
        if user_id_in is null then
            return 1;
        end if;
        return user_role_check(channel_id_in, user_id_in, role_in);
    end loose_user_role_check;
    
    -- directly checks the table, no inferred permissions
    function direct_user_role_check(channel_id_in in number, user_id_in in number, role_in in varchar2)
    return number
    is
        throwaway number;
    begin
        -- the idea: if we get past this query, the user has the role, else catch the exception and return 0
        select 1 into throwaway
          from rhnChannelPermissionRole CPR,
               rhnChannelPermission CP
         where CP.user_id = user_id_in
           and CP.channel_id = channel_id_in
           and CPR.label = role_in
           and CP.role_id = CPR.id;
           
        return 1;
    exception
        when no_data_found
            then
            return 0;
    end;
    
    -- check if an org has a certain setting
    function org_channel_setting(channel_id_in in number, org_id_in in number, setting_in in varchar2)
    return number
    is
        throwaway number;
    begin
        -- the idea: if we get past this query, the org has the setting, else catch the exception and return 0
        select 1 into throwaway
          from rhnOrgChannelSettingsType OCST,
               rhnOrgChannelSettings OCS
         where OCS.org_id = org_id_in
           and OCS.channel_id = channel_id_in
           and OCST.label = setting_in
           and OCS.setting_id = OCST.id;
           
        return 1;
    exception
        when no_data_found
            then
            return 0;
    end;
    
    FUNCTION channel_priority(channel_id_in IN number) 
    RETURN number
    IS
         channel_name varchar2(256);
         priority number;
         end_of_life_val date;
         org_id_val number;
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

    end channel_priority;

    -- right now this only does the accounting changes; the cascade
    -- actually does the rhnServerChannel delete.
    procedure delete_server_channels(server_id_in in number)
    is
    begin
        update  rhnPrivateChannelFamily
        set     current_members = current_members -1
        where   org_id in (
                        select  org_id
                        from    rhnServer
                        where   id = server_id_in
                )
                and channel_family_id in (
                        select  rcfm.channel_family_id
                        from    rhnChannelFamilyMembers rcfm,
                                rhnServerChannel rsc
                        where   rsc.server_id = server_id_in
                                and rsc.channel_id = rcfm.channel_id
                and not exists (
                    select 1
                    from
                        rhnChannelFamilyVirtSubLevel cfvsl,
                        rhnSGTypeVirtSubLevel sgtvsl,
                        rhnServerEntitlementView sev,
                        rhnVirtualInstance vi
                    where
                        -- system is a virtual instance
                        vi.virtual_system_id = server_id_in
                        and vi.host_system_id = sev.server_id
                        -- system's host has a virt ent
                        and sev.label in ('virtualization_host',
                                          'virtualization_host_platform')
                        and sev.server_group_type_id = 
                            sgtvsl.server_group_type_id
                        -- the host's virt ent grants a cf virt sub level
                        and sgtvsl.virt_sub_level_id = cfvsl.virt_sub_level_id
                        -- the cf is in that virt sub level
                        and cfvsl.channel_family_id = rcfm.channel_family_id
                    )
                );
    end;

        -- this could certainly be optimized to do updates if needs be
        procedure refresh_newest_package(channel_id_in in number, caller_in in varchar2 := '(unknown)')
        is
        begin
                delete from rhnChannelNewestPackage where channel_id = channel_id_in;
                insert into rhnChannelNewestPackage
                        ( channel_id, name_id, evr_id, package_id, package_arch_id ) 
                        (       select  channel_id,
                                                name_id, evr_id,
                                                package_id, package_arch_id
                                from    rhnChannelNewestPackageView
                                where   channel_id = channel_id_in
                        );
                insert into rhnChannelNewestPackageAudit (channel_id, caller)
                    values (channel_id_in, caller_in);
                update rhnChannel 
                    set last_modified = greatest(sysdate, last_modified + 1/86400)
                    where id = channel_id_in; 
        end;

   procedure update_channel ( channel_id_in in number, invalidate_ss in number := 0, 
                              date_to_use in date := sysdate )
   is

   channel_last_modified date;
   last_modified_value date;

   cursor snapshots is
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
          last_modified_value := last_modified_value + 1/86400;
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

   end update_channel;

   procedure update_channels_by_package ( package_id_in in number, date_to_use in date := sysdate )
   is

   cursor channels is
   select channel_id
   from rhnChannelPackage
   where package_id = package_id_in
   order by channel_id;

   begin
      for channel in channels loop
         -- we want to invalidate the snapshot assocated with the channel when we
         -- do this b/c we know we've added or removed or packages
         rhn_channel.update_channel ( channel.channel_id, 1, date_to_use );
      end loop;
   end update_channels_by_package;

   
   procedure update_channels_by_errata ( errata_id_in number, date_to_use in date := sysdate )
   is

   cursor channels is
   select channel_id
   from rhnChannelErrata
   where errata_id = errata_id_in
   order by channel_id;

   begin
      for channel in channels loop
         -- we won't invalidate snapshots, b/c just changing the errata associated with
         -- a channel shouldn't invalidate snapshots
         rhn_channel.update_channel ( channel.channel_id, 0, date_to_use );
      end loop;
   end update_channels_by_errata;

END rhn_channel;
/
SHOW ERRORS

--
-- Revision 1.75  2005/03/04 00:04:19  jslagle
-- bz #147617
-- Made Red Hat Desktop sort a little better.
--
-- Revision 1.74  2005/02/22 03:24:47  jslagle
-- bz #147617
-- Improve channel_priority function to order channels better.
--
-- Revision 1.73  2004/08/16 20:39:30  pjones
-- bugzilla: 129889 -- make bulk_server_basechange_from() actually work.
--
-- Revision 1.72  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
-- Revision 1.71  2004/04/13 16:28:36  bretm
-- bugzilla:  119871
--
-- keep track of rhnServer.channels_changed through the pl/sql fns
--
-- Revision 1.70  2004/03/26 18:11:32  rbb
-- Bugzilla:  114057
--
-- Add a script to determine channel priority.
--
-- Revision 1.69  2004/02/17 20:16:52  pjones
-- bugzilla: none -- add cvs tags into the package as long as we're touching
-- it anyway
--
-- Revision 1.68  2004/02/17 20:05:38  pjones
-- bugzilla: 115782 -- make bulk_server_basechange_from() filter out servers
-- with arches incompatible with the target channel
--
-- Revision 1.67  2004/02/06 02:36:10  misa
-- Changed normalize_server_arch to allow for solaris arches
--
-- Revision 1.66  2003/11/13 16:58:34  cturner
-- make use of new rhn_user.check_role_implied call; pragmas broke, removed them for now since I have no idea how to fix them
--
-- Revision 1.65  2003/10/23 20:26:24  bretm
-- bugzilla:  none
--
-- note the channel label when we unsubscribe, too
--
-- Revision 1.64  2003/10/15 14:47:17  bretm
-- bugzilla:  none
--
-- add the channel label to the server history summary line when we log a channel change
--
-- Revision 1.63  2003/09/24 19:25:56  pjones
-- this wasn't the right fix, put it back
--
-- Revision 1.62  2003/09/24 17:42:19  pjones
-- bugzilla: none
--
-- limit our server base channel guess to channels with available permissions
--
-- Revision 1.61  2003/09/22 21:00:40  cturner
-- add method for easy acl check
--
-- Revision 1.60  2003/09/17 22:14:11  misa
-- bugzilla: 103639  Changes to allow me to move the base channel guess into plsql
--
-- Revision 1.59  2003/08/21 13:41:17  cturner
-- bugzilla: 99187.  properly test for satellite and proxy in bulk_guess_server_base; reorg code for better reuse
--
-- Revision 1.58  2003/07/24 16:46:22  cturner
-- bugzilla: 100723, the perm check was returning duplicates, so now it just calls the function it should have called anyway
--
-- Revision 1.57  2003/07/24 16:44:16  misa
-- bugzilla: none  A function more usable on the rhnapp side
--
-- Revision 1.56  2003/07/23 22:36:51  cturner
-- argh, max returns null even when now rows; use distinct.  how revolting
--
-- Revision 1.55  2003/07/23 22:01:31  cturner
-- oops, this one can return multiple rows; eliminate that in a lazy way
--
-- Revision 1.54  2003/07/23 21:59:19  cturner
-- rework how rhnUserChannel works; move to plsql for speed and maintenance
--
-- Revision 1.53  2003/07/21 17:49:12  pjones
-- bugzilla: none
--
-- add optional user for subscribe_server
--
-- Revision 1.52  2003/07/14 22:19:29  misa
-- bugzilla: none  Updating guess_base_channel to work more like the rhnapp server code
--
-- Revision 1.51  2003/06/26 22:09:04  pjones
-- bugzilla: none
--
-- log subscribe and unsubscribe
--
-- Revision 1.50  2003/06/05 19:31:15  pjones
-- bugzilla: 88278 -- make the cursor name smaller
--
-- Revision 1.49  2003/06/05 19:18:21  pjones
-- bugzilla: 88278
--
-- unsubscribe_server() opens the package-level cursor when it invokes itself,
-- so we're using a local copy instead.
--
-- Revision 1.48  2003/06/04 16:41:39  pjones
-- bugzilla: none
--
-- make bulk_guess_server_base() silently ignore unguessables
--
-- Revision 1.47  2003/06/04 16:27:03  pjones
-- bugzilla: 88822
--
-- eliminate the last outliers that remove things from channels without using
-- unsubscribe_server, I think.
--
-- Revision 1.46  2003/06/03 20:49:37  pjones
-- bugzilla: 88822
-- unsubscribing from rhn-satellite now clears rhnSatelliteChannelFamily
-- for the server in question
--
-- Revision 1.45  2003/06/02 20:41:45  pjones
-- bugzilla: none - fix rhnProxyInfo/rhnSatelliteInfo channel unsubscribe
-- problem.  Basicly, if you're out of the channel for any reason, you're
-- also out of rhnProxyInfo/rhnProxyInfo
--
-- Revision 1.44  2003/03/24 15:26:28  pjones
-- bugzilla: 85812
--
-- bulk_server_base_change silently ignores servers that are satellites
-- or proxies, as requested.
--
-- Revision 1.43  2003/02/26 20:28:17  pjones
-- rhn_channel.update_family_counts() in rhn_channel.entitle_customer()
-- the old codepath is:
--
-- ep ->
-- rhn_ep.entitlement_run_me() ->
-- rhn_ep.poll_customer() ->
-- rhn_channel.entitle_customer()
--
-- which doesn't change current_members, even though it may remove servers
-- from the family.
--
-- There's another bug here:  currently, we don't try to order forced
-- unsubscribes in any way; we just use
-- rhn_channel.unsubscribe_server_from_family .  If there are any child
-- channel subscriptions, this will leave them subscribed.  We really need
-- to iterate across the channels again, and subscribe any channel for which
-- there are no parent channel subscriptions.
--
-- Ugh.
--
-- Revision 1.42  2003/01/28 00:19:45  pjones
-- fix clear_subscriptions; AFAICT, this is only hit on the
-- bulk_server_base_change / bulk_server_base_guess codepaths, which puts
-- it infrequent enough that it could be our "bad count" culprit.
--
-- Revision 1.41  2003/01/14 19:51:45  pjones
-- make setting current_members on rhnChannelFamilyPermissions work when
-- a server is in more than one channel in a single family.
