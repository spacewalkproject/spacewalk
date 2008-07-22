SET ECHO ON;
whenever sqlerror exit failure;

spool satellite-5.1-to-5.2.log;

variable evr_id number;
variable epoch varchar2(16);
variable version varchar2(64);
variable release varchar2(64);

variable message varchar2(80);

declare
   cursor evrs is
      select   e.id, e.epoch, e.version, e.release, e.evr
      from  rhnPackageEVR e,
         rhnVersionInfo rvi
      where rvi.label = 'schema'
         and rvi.name_id =
            lookup_package_name('rhn-satellite-schema')
         and rvi.evr_id = e.id;
   cursor valid_evrs is
      select   1
      from  dual
      where :evr_id in (
         lookup_evr('','5.1.0','27')
         );
begin
   :evr_id := null;
   :message := 'XXX Invalid satellite schema version.';
   for evr in evrs loop
      :evr_id := evr.id;
      :epoch := evr.epoch;
      :version := evr.version;
      :release := evr.release;
      :message :=  '*** Schema version is currently ' ||
         evr.evr.as_vre_simple() ||
         ', and will NOT be upgraded';
      for vevr in valid_evrs loop
         :message :=  '*** Schema version is currently ' ||
            evr.evr.as_vre_simple() ||
            ', and will be upgraded';
      end loop;
      return;
   end loop;
end;
/
show errors;


select :message from dual;

declare
   invalid_schema_version exception;
   cursor valid_evrs is
      select   1
      from  dual
      where :evr_id in (
         lookup_evr('','5.1.0','27')
         );
begin
   for vevr in valid_evrs loop
      return;
   end loop;
   raise invalid_schema_version;
end;
/
show errors;

set define off;

-- Upgrade body

alter table web_customer drop column password ;

-- bugzilla: 444841
-- views/rhnPrivateErrataMail.sql
create or replace view
rhnPrivateErrataMail
as
with rhnSPmaxEVR as (
   select   sq2_sp.server_id, sq2_sp.name_id, max(sq2_pe.evr) max_evr
            from  rhnServerPackage  sq2_sp,
               rhnPackageEVR     sq2_pe
            where sq2_sp.evr_id = sq2_pe.id
	    group by sq2_sp.server_id, sq2_sp.name_id)
select
   w.login,
   w.login_uc,
   wpi.email,
   w.id user_id,
   s.id server_id,
   -- use sg here so we can start with org and work to errata from there
   w.org_id org_id,
   s.name server_name,
   sa.name server_arch,
   s.release server_release,
   ce.errata_id errata_id,
   e.advisory
from
   rhnServer s,
   web_user_personal_info wpi,
   rhnUserInfo ui,
   rhnErrata e,
   rhnServerArch sa,
   rhnChannelErrata ce,
   web_contact w,
   rhnServerChannel sc,
   rhnServerGroupMembers sgm,
   rhnServerGroup sg
where 1=1
   -- we plan on starting with org_id, and server group is the
   -- best place to find that that's near servers
   and sg.id = sgm.server_group_id
   and sgm.server_id = sc.server_id
   -- then find the contacts, because permission checking is next
   and sg.org_id = w.org_id
   -- filter out users who don't want mail about this server
   -- they get an entry if they _don't_ want mail
   and not exists (
      select   usprefs.server_id
               from  rhnUserServerPrefs usprefs
         where 1=1
         and w.id = usprefs.user_id
               and sc.server_id = usprefs.server_id
               and usprefs.name = 'receive_notifications'
   )
   -- filter out users who don't want/can't get email
   and w.id = wpi.web_user_id
   and wpi.email is not null
   and w.id = ui.user_id
      and ui.email_notify = 1
      -- check permissions. For this query being an org admin is the
      -- most common thing, so we test for that first
   and exists (
      select   1
      from
         rhnUserGroupType  ugt,
         rhnUserGroup      ug,
         rhnUserGroupMembers  ugm
      where 1=1
         and ugt.label = 'org_admin'
         and ugt.id = ug.group_type
         and ug.id = ugm.user_group_id
         and ugm.user_id = w.id
      union all
      select   1
      from
         rhnServerGroupMembers   sq_sgm,
         rhnUserServerGroupPerms usg
      where sc.server_id = sq_sgm.server_id
         and sq_sgm.server_group_id = usg.server_group_id
         and usg.user_id = w.id
   )
   -- filter out servers that aren't in useful channels
   and sc.channel_id = ce.channel_id
   -- find the server, so we can do s.arch comparisons
   and sc.server_id = s.id
      and exists (
         select 1
      from
            rhnPackageEVR        p_evr,
            rhnPackageEVR        sp_evr,
            rhnServerPackage     sp,
            rhnChannelPackage    cp,
            rhnPackage        p,
            rhnErrataPackage     ep,
            rhnServerPackageArchCompat spac
      where 1=1
         -- packages from channels this server is subscribed to
         and sc.channel_id = cp.channel_id
         and cp.package_id = p.id
         -- part of an errata
         and ce.errata_id = ep.errata_id
         and ep.package_id = p.id
         -- and that errata maps back to the server channel
         and sc.channel_id = ce.channel_id
         and ce.errata_id = ep.errata_id
         -- also installed on this server
         and sc.server_id = sp.server_id
         and sp.name_id = p.name_id
         and sp.evr_id = sp_evr.id
         -- different evr
         and p.evr_id = p_evr.id
         and sp.evr_id != p.evr_id
         -- and newer evr
         and sp_evr.evr < p_evr.evr
         and sp_evr.evr = (
            select max_evr from rhnSPmaxEVR rsme
	    where sp.server_id = rsme.server_id
               and sp.name_id = rsme.name_id
         )
         -- compat arch
         and p.package_arch_id = spac.package_arch_id
         and s.server_arch_id = spac.server_arch_id
   )
   -- below here isn't needed except for output
   and s.server_arch_id = sa.id
   and ce.errata_id = e.id
   and not exists ( select 1
                      from rhnWebContactDisabled wcd
                     where wcd.id = w.id )
/

-- deterministic hint fix
-- svn r174754

CREATE OR REPLACE
PACKAGE BODY rhn_channel
IS
	body_version varchar2(100) := '$Id: rhn_channel.pkb 174675 2008-07-02 13:32:24Z mmraka $';

    -- Cursor that fetches all the possible base channels for a
    -- (server_arch_id, release, org_id) combination
	cursor	base_channel_cursor(
		release_in in varchar2,
		server_arch_id_in in number,
		org_id_in in number
	) return rhnChannel%ROWTYPE is
		select distinct c.*
		from	rhnDistChannelMap			dcm,
				rhnServerChannelArchCompat	scac,
				rhnChannel					c,
				rhnChannelPermissions		cp
		where	cp.org_id = org_id_in
			and cp.channel_id = c.id
			and c.parent_channel is null
			and c.id = dcm.channel_id
			and c.channel_arch_id = dcm.channel_arch_id
			and dcm.release = release_in
			and scac.server_arch_id = server_arch_id_in
			and scac.channel_arch_id = c.channel_arch_id;

    FUNCTION get_license_path(channel_id_in IN NUMBER)
    RETURN VARCHAR2
    IS
	license_val VARCHAR2(1000);
    BEGIN
	SELECT CFL.license_path INTO license_val
	  FROM rhnChannelFamilyLicense CFL, rhnChannelFamilyMembers CFM
	 WHERE CFM.channel_id = channel_id_in
	   AND CFM.channel_family_id = CFL.channel_family_id;

	RETURN license_val;

    EXCEPTION
	WHEN NO_DATA_FOUND
	    THEN
	    RETURN NULL;
    END get_license_path;


    PROCEDURE license_consent(channel_id_in IN NUMBER, user_id_in IN NUMBER, server_id_in IN NUMBER)
    IS
	channel_family_id_val NUMBER;
    BEGIN
	channel_family_id_val := rhn_channel.family_for_channel(channel_id_in);
	IF channel_family_id_val IS NULL
	THEN
	    rhn_exception.raise_exception('channel_subscribe_no_family');
	END IF;

	IF rhn_channel.get_license_path(channel_id_in) IS NULL
	THEN
	    rhn_exception.raise_exception('channel_consent_no_license');
	END IF;

	INSERT INTO rhnChannelFamilyLicenseConsent (channel_family_id, user_id, server_id)
	VALUES (channel_family_id_val, user_id_in, server_id_in);
    END license_consent;

    PROCEDURE subscribe_server(server_id_in IN NUMBER, channel_id_in NUMBER, immediate_in NUMBER := 1, user_id_in in number := null)
    IS
        channel_parent_val      rhnChannel.parent_channel%TYPE;
        parent_subscribed       BOOLEAN;
        server_has_base_chan    BOOLEAN;
	server_already_in_chan  BOOLEAN;
	channel_family_id_val   NUMBER;
	server_org_id_val       NUMBER;
	available_subscriptions NUMBER;
	consenting_user         NUMBER;
	allowed			number := 0;
    current_members_val     number;
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

	SELECT org_id INTO server_org_id_val
	  FROM rhnServer
	 WHERE id = server_id_in;

    select current_members
    into current_members_val
    from rhnPrivateChannelFamily
    where org_id = server_org_id_val and channel_family_id = channel_family_id_val
    for update of current_members;

	available_subscriptions := rhn_channel.available_family_subscriptions(channel_family_id_val, server_org_id_val);

	IF available_subscriptions IS NULL OR
       available_subscriptions > 0 or
       can_server_consume_virt_channl(server_id_in, channel_family_id_val) = 1
	THEN

	    IF rhn_channel.get_license_path(channel_id_in) IS NOT NULL
	    THEN
		BEGIN

		SELECT user_id INTO consenting_user
		  FROM rhnChannelFamilyLicenseConsent
		 WHERE channel_family_id = channel_family_id_val
		   AND server_id = server_id_in;

		EXCEPTION
		    WHEN NO_DATA_FOUND
			THEN
			    rhn_exception.raise_exception('channel_subscribe_no_consent');
		END;
	    END IF;

	    insert into rhnServerHistory (id,server_id,summary,details) (
		select	rhn_event_id_seq.nextval,
			server_id_in,
			'subscribed to channel ' || SUBSTR(c.label, 0, 106),
			c.label
		from	rhnChannel c
		where	c.id = channel_id_in
	    );
	    UPDATE rhnServer SET channels_changed = sysdate WHERE id = server_id_in;
            INSERT INTO rhnServerChannel (server_id, channel_id) VALUES (server_id_in, channel_id_in);

	    rhn_channel.update_family_counts(channel_family_id_val, server_org_id_val);
	    queue_server(server_id_in, immediate_in);
	ELSE
	    rhn_exception.raise_exception('channel_family_no_subscriptions');
	END IF;

    END subscribe_server;

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


    PROCEDURE bulk_subscribe_server(channel_id_in IN NUMBER, set_label_in IN VARCHAR2, set_uid_in IN NUMBER)
    IS
    BEGIN
        FOR server IN rhn_set.set_iterator(set_label_in, set_uid_in)
        LOOP
            rhn_channel.subscribe_server(server.element, channel_id_in, 0, set_uid_in);
        END LOOP server;
    END bulk_subscribe_server;

    PROCEDURE bulk_server_base_change(channel_id_in IN NUMBER, set_label_in IN VARCHAR2, set_uid_in IN NUMBER)
    IS
    BEGIN
        FOR server IN rhn_set.set_iterator(set_label_in, set_uid_in)
        LOOP
	    IF rhn_server.can_change_base_channel(server.element) = 1
	    THEN
                rhn_channel.clear_subscriptions(TO_NUMBER(server.element));
                rhn_channel.subscribe_server(server.element, channel_id_in, 0, set_uid_in);
            END IF;
        END LOOP server;
    END bulk_server_base_change;

    procedure bulk_server_basechange_from(
        set_label_in in varchar2,
        set_uid_in in number,
        old_channel_id_in in number,
        new_channel_id_in in number
    ) is
    cursor servers is
        select  sc.server_id id
        from    rhnChannel nc,
                rhnServerChannelArchCompat scac,
                rhnServer s,
                rhnChannel oc,
                rhnServerChannel sc,
                rhnSet st
        where   1=1
            -- first, find the servers we're looking for.
            and st.label = set_label_in
            and st.user_id = set_uid_in
            and st.element = sc.server_id
            -- now, filter out anything that's not in the
            -- old base channel.
            and sc.channel_id = old_channel_id_in
            and sc.channel_id = oc.id
            and oc.parent_channel is null
            -- now, see if it's compatible with the new base channel
            and nc.id = new_channel_id_in
            and nc.parent_channel is null
            and sc.server_id = s.id
            and s.server_arch_id = scac.server_arch_id
            and scac.channel_arch_id = nc.channel_arch_id;
    begin
        for s in servers loop
            insert into rhnSet (
                    user_id, label, element
                ) values (
                    set_uid_in,
                    set_label_in || 'basechange',
                    s.id
                );
        end loop channel;
        bulk_server_base_change(new_channel_id_in,
                                set_label_in || 'basechange',
                                set_uid_in);
        delete from rhnSet
            where   label = set_label_in||'basechange'
                and user_id = set_uid_in;
    end bulk_server_basechange_from;

    procedure bulk_guess_server_base(
	set_label_in in varchar2,
	set_uid_in in number
    ) is
	channel_id number;
    begin
	for server in rhn_set.set_iterator(set_label_in, set_uid_in)
	loop
	    -- anything that doesn't work, we just ignore
	    begin
		if rhn_server.can_change_base_channel(server.element) = 1
		then
	            channel_id := guess_server_base(TO_NUMBER(server.element));
		    rhn_channel.clear_subscriptions(TO_NUMBER(server.element));
		    rhn_channel.subscribe_server(TO_NUMBER(server.element), channel_id, 0, set_uid_in);
		end if;
	    exception when others then
		null;
	    end;
	end loop server;
    end;

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

    procedure bulk_guess_server_base_from(
	set_label_in in varchar2,
	set_uid_in in number,
	channel_id_in in number
    ) is
	cursor channels(server_id_in in number) is
	    select	rsc.channel_id
	    from	rhnServerChannel rsc,
			rhnChannel rc
	    where	server_id_in = rsc.server_id
			and rsc.channel_id = rc.id
			and rc.parent_channel is null;
    begin
	for server in rhn_set.set_iterator(set_label_in, set_uid_in)
	loop
	    for channel in channels(server.element)
	    loop
		if channel.channel_id = channel_id_in
		then
		    insert into rhnSet (user_id, label, element) values (set_uid_in, set_label_in || 'baseguess', server.element);
		end if;
	    end loop channel;
	end loop server;
	bulk_guess_server_base(set_label_in||'baseguess',set_uid_in);
	delete from rhnSet where label = set_label_in||'baseguess' and user_id = set_uid_in;
    end;


    PROCEDURE clear_subscriptions(server_id_in IN NUMBER, deleting_server IN NUMBER := 0 )
    IS
	cursor server_channels(server_id_in in number) is
		select	s.org_id, sc.channel_id, cfm.channel_family_id
		from	rhnServer s,
			rhnServerChannel sc,
			rhnChannelFamilyMembers cfm
		where	s.id = server_id_in
			and s.id = sc.server_id
			and sc.channel_id = cfm.channel_id;
    BEGIN
	for channel in server_channels(server_id_in)
	loop
		unsubscribe_server(server_id_in, channel.channel_id, 1, 1, deleting_server);
		rhn_channel.update_family_counts(channel.channel_family_id, channel.org_id);
	end loop channel;
    END clear_subscriptions;

    PROCEDURE unsubscribe_server(server_id_in IN NUMBER, channel_id_in NUMBER, immediate_in NUMBER := 1, unsubscribe_children_in number := 0,
                                 deleting_server IN NUMBER := 0 )
    IS
	channel_family_id_val   NUMBER;
	server_org_id_val       NUMBER;
	available_subscriptions NUMBER;
	server_already_in_chan  BOOLEAN;
	cursor	channel_family_is_proxy(channel_family_id_in in number) is
		select	1
		from	rhnChannelFamily
		where	id = channel_family_id_in
		    and label = 'rhn-proxy';
	cursor	channel_family_is_satellite(channel_family_id_in in number) is
		select	1
		from	rhnChannelFamily
		where	id = channel_family_id_in
		    and label = 'rhn-satellite';
	-- this is *EXACTLY* like check_server_parent_membership, but if we recurse
	-- with the package-level one, we get a "cursor already open", so we need a
	-- copy on our call stack instead.  GROAN.
	cursor local_chk_server_parent_memb (
			server_id_in number,
			channel_id_in number ) is
		select	c.id
		from	rhnChannel			c,
				rhnServerChannel	sc
		where	1=1
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
                        deleting_server => deleting_server);
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

	DELETE FROM rhnChannelFamilyLicenseConsent
	 WHERE channel_family_id = channel_family_id_val
	   AND server_id = server_id_in;

	SELECT org_id INTO server_org_id_val
	  FROM rhnServer
	 WHERE id = server_id_in;

	rhn_channel.update_family_counts(channel_family_id_val, server_org_id_val);
    END unsubscribe_server;

    PROCEDURE bulk_unsubscribe_server(channel_id_in IN NUMBER, set_label_in IN VARCHAR2, set_uid_in IN NUMBER)
    IS
    BEGIN
        FOR server IN rhn_set.set_iterator(set_label_in, set_uid_in)
        LOOP
            rhn_channel.unsubscribe_server(server.element, channel_id_in, 0);
        END LOOP server;
    END bulk_unsubscribe_server;

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
        select	count(sc.server_id)
        into    current_members_count
        from	rhnChannelFamilyMembers cfm,
                rhnServerChannel sc,
                rhnServer s
        where	s.org_id = org_id_in
            and s.id = sc.server_id
            and cfm.channel_family_id = channel_family_id_in
            and cfm.channel_id = sc.channel_id
            and exists (
                select 1
                from rhnChannelFamilyServerPhysical cfsp
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
		set current_members = (
                channel_family_current_members(channel_family_id_in, org_id_in)
		)
			where org_id = org_id_in
				and channel_family_id = channel_family_id_in;
    END update_family_counts;

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

    -- *******************************************************************
    -- PROCEDURE: entitle_customer
    -- Creates a chan fam bucket, or sets max_members for an existing bucket
    -- Called by: rhn_ep.poll_customer_internal
    -- Calls: set_family_maxmembers + update_family_counts if the row
    --        already exists, else it creates it in rhnPrivateChannelFamily.
    -- *******************************************************************
    procedure entitle_customer(customer_id_in in number,
                               channel_family_id_in in number,
                               quantity_in in number)
    is
		cursor permissions is
			select	1
			from	rhnPrivateChannelFamily pcf
			where	pcf.org_id = customer_id_in
				and	pcf.channel_family_id = channel_family_id_in;
    begin
		for perm in permissions loop
			set_family_maxmembers(
				customer_id_in,
				channel_family_id_in,
				quantity_in
			);
			rhn_channel.update_family_counts(
				channel_family_id_in,
				customer_id_in
			);
			return;
		end loop;

		insert into rhnPrivateChannelFamily pcf (
				channel_family_id, org_id, max_members, current_members
			) values (
				channel_family_id_in, customer_id_in, quantity_in, 0
			);
    end;

    -- *******************************************************************
    -- PROCEDURE: set_family_maxmembers
    -- Prunes an existing channel family bucket by unsubscribing the
    --   necessary servers and sets max_members.
    -- Called by: rhn_channel.entitle_customer
    -- Calls: unsubscribe_server_from_family
    -- *******************************************************************
    procedure set_family_maxmembers(customer_id_in in number,
                                    channel_family_id_in in number,
                                    quantity_in in number)
    is
        cursor servers is
            select  server_id from (
            select	rownum row_number, server_id, modified from (
                select  rcfsp.server_id,
                        rcfsp.modified
                from    rhnChannelFamilyServerPhysical rcfsp
                where   rcfsp.customer_id = customer_id_in
                    and rcfsp.channel_family_id = channel_family_id_in
                order by modified
            )
            where rownum > quantity_in
            );
    begin
	    -- prune subscribed servers
        for server in servers loop
            rhn_channel.unsubscribe_server_from_family(server.server_id,
                                                       channel_family_id_in);
        end loop;

        update	rhnPrivateChannelFamily pcf
        set	pcf.max_members = quantity_in
        where	pcf.org_id = customer_id_in
            and pcf.channel_family_id = channel_family_id_in;
    end;

    procedure unsubscribe_server_from_family(server_id_in in number,
                                             channel_family_id_in in number)
    is
    begin
        delete
        from	rhnServerChannel rsc
        where	rsc.server_id = server_id_in
            and channel_id in (
                select	rcfm.channel_id
                from	rhnChannelFamilyMembers rcfm
                where	rcfm.channel_family_id = channel_family_id_in);
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
	cursor	families is
			select	1
			from	rhnOrgChannelFamilyPermissions cfp
			where	cfp.org_id = org_id_in;
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
         channel_name varchar2(64);
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
	update	rhnPrivateChannelFamily
	set	current_members = current_members -1
	where	org_id in (
			select	org_id
			from	rhnServer
			where	id = server_id_in
		)
		and channel_family_id in (
			select	rcfm.channel_family_id
			from	rhnChannelFamilyMembers rcfm,
				rhnServerChannel rsc
			where	rsc.server_id = server_id_in
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
			(	select	channel_id,
						name_id, evr_id,
						package_id, package_arch_id
				from	rhnChannelNewestPackageView
				where	channel_id = channel_id_in
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

CREATE OR REPLACE
PACKAGE rhn_package
IS
    CURSOR channel_occupancy_cursor(package_id_in IN NUMBER) IS
    SELECT C.id channel_id, C.name channel_name
      FROM rhnChannel C,
	   rhnChannelPackage CP
     WHERE C.id = CP.channel_id
       AND CP.package_id = package_id_in
     ORDER BY C.name DESC;

    FUNCTION canonical_name(name_in IN VARCHAR2, evr_in IN EVR_T,
	                    arch_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2
      DETERMINISTIC;

    FUNCTION channel_occupancy_string(package_id_in IN NUMBER, separator_in VARCHAR2 := ', ')
      RETURN VARCHAR2;

END rhn_package;
/

CREATE OR REPLACE PACKAGE rpm AS
    FUNCTION vercmp(
        e1 VARCHAR2, v1 VARCHAR2, r1 VARCHAR2,
        e2 VARCHAR2, v2 VARCHAR2, r2 VARCHAR2)
    RETURN NUMBER
        DETERMINISTIC
        PARALLEL_ENABLE;
    PRAGMA RESTRICT_REFERENCES(vercmp, WNDS, RNDS);

    FUNCTION vercmpCounter
    return NUMBER
        PARALLEL_ENABLE;
    PRAGMA RESTRICT_REFERENCES(vercmpCounter, WNDS, RNDS);

    FUNCTION vercmpResetCounter
    return NUMBER
        PARALLEL_ENABLE;
    PRAGMA RESTRICT_REFERENCES(vercmpResetCounter, WNDS, RNDS);

END rpm;
/

CREATE OR REPLACE PACKAGE BODY rpm AS
    vercmp_counter NUMBER := 0;

    FUNCTION isdigit(ch CHAR)
    RETURN BOOLEAN
    deterministic
    IS
    BEGIN
        if ascii(ch) between ascii('0') and ascii('9')
        then
            return TRUE;
        end if;
        return FALSE;
    END isdigit;


    FUNCTION isalpha(ch CHAR)
    RETURN BOOLEAN
    deterministic
    IS
    BEGIN
        if ascii(ch) between ascii('a') and ascii('z') or
            ascii(ch) between ascii('A') and ascii('Z')
        then
            return TRUE;
        end if;
        return FALSE;
    END isalpha;


    FUNCTION isalphanum(ch CHAR)
    RETURN BOOLEAN
    deterministic
    IS
    BEGIN
        if ascii(ch) between ascii('a') and ascii('z') or
            ascii(ch) between ascii('A') and ascii('Z') or
            ascii(ch) between ascii('0') and ascii('9')
        then
            return TRUE;
        end if;
        return FALSE;
    END isalphanum;


    FUNCTION rpmstrcmp (string1 IN VARCHAR2, string2 IN VARCHAR2)
    RETURN NUMBER
    deterministic
    IS
        digits CHAR(10) := '0123456789';
        lc_alpha CHAR(27) := 'abcdefghijklmnopqrstuvwxyz';
        uc_alpha CHAR(27) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        alpha CHAR(54) := lc_alpha || uc_alpha;
        str1 VARCHAR2(32767) := string1;
        str2 VARCHAR2(32767) := string2;
        one VARCHAR2(32767);
        two VARCHAR2(32767);
        isnum BOOLEAN;
    BEGIN
        if str1 is NULL or str2 is NULL
        then
            raise VALUE_ERROR;
        end if;
        -- easy comparison to see if versions are identical
        if str1 = str2
        then
            return 0;
        end if;
        -- loop through each version segment of str1 and str2 and compare them
        one := str1;
        two := str2;

        <<segment_loop>>
        while one is not null and two is not null
        loop
            declare
                segm1 VARCHAR2(32767);
                segm2 VARCHAR2(32767);
            begin
                --DBMS_OUTPUT.PUT_LINE('Params: ' || one || ',' || two);
                -- Throw out all non-alphanum characters
                while one is not null and not isalphanum(one)
                loop
                    one := substr(one, 2);
                end loop;
                while two is not null and not isalphanum(two)
                loop
                    two := substr(two, 2);
                end loop;
                --DBMS_OUTPUT.PUT_LINE('new params: ' || one || ',' || two);

                str1 := one;
                str2 := two;

                /* grab first completely alpha or completely numeric segment */
                /* leave one and two pointing to the start of the alpha or numeric */
                /* segment and walk str1 and str2 to end of segment */

                if str1 is not null and isdigit(str1)
                then
                    str1 := ltrim(str1, digits);
                    str2 := ltrim(str2, digits);
                    isnum := true;
                else
                    str1 := ltrim(str1, alpha);
                    str2 := ltrim(str2, alpha);
                    isnum := false;
                end if;

                --DBMS_OUTPUT.PUT_LINE('Len: ' || length(str1) || ',' || length(str2));
                -- Oracle trats the length of an empty string as null
                if str1 is not null
                then segm1 := substr(one, 1, length(one) - length(str1));
                else segm1 := one;
                end if;

                if str2 is not null
                then segm2 := substr(two, 1, length(two) - length(str2));
                else segm2 := two;
                end if;

                --DBMS_OUTPUT.PUT_LINE('Segments: ' || segm1 || ',' || segm2);
                --DBMS_OUTPUT.PUT_LINE('Rest: ' || str1 || ',' || str2);
                /* take care of the case where the two version segments are */
                /* different types: one numeric and one alpha */
                if segm1 is null then return -1; end if; /* arbitrary */
                if segm2 is null then
					if isnum then
						return 1;
					else
						return -1;
					end if;
				end if;

                if isnum
                then
                    /* this used to be done by converting the digit segments */
                    /* to ints using atoi() - it's changed because long */
                    /* digit segments can overflow an int - this should fix that. */

                    /* throw away any leading zeros - it's a number, right? */
                    segm1 := ltrim(segm1, '0');
                    segm2 := ltrim(segm2, '0');

                    /* whichever number has more digits wins */
                    -- length of empty string is null
                    if segm1 is null and segm2 is not null
                    then
                        return -1;
                    end if;
                    if segm1 is not null and segm2 is null
                    then
                        return 1;
                    end if;
                    if length(segm1) > length(segm2) then return 1; end if;
                    if length(segm2) > length(segm1) then return -1; end if;
                end if;

                /* strcmp will return which one is greater - even if the two */
                /* segments are alpha or if they are numeric.  don't return  */
                /* if they are equal because there might be more segments to */
                /* compare */

                if segm1 < segm2 then return -1; end if;
                if segm1 > segm2 then return 1; end if;

                one := str1;
                two := str2;
            end;
        end loop segment_loop;
        /* this catches the case where all numeric and alpha segments have */
        /* compared identically but the segment sepparating characters were */
        /* different */
        if one is null and two is null then return 0; end if;

        /* whichever version still has characters left over wins */
        if one is null then return -1; end if;
        return 1;
    END rpmstrcmp;


    FUNCTION vercmp(
        e1 VARCHAR2, v1 VARCHAR2, r1 VARCHAR2,
        e2 VARCHAR2, v2 VARCHAR2, r2 VARCHAR2)
    RETURN NUMBER
    IS
        rc NUMBER;
    BEGIN
        DECLARE
          ep1 NUMBER;
          ep2 NUMBER;
          BEGIN
            vercmp_counter := vercmp_counter + 1;
            if e1 is null then
              ep1 := 0;
            else
              ep1 := TO_NUMBER(e1);
            end if;
            if e2 is null then
              ep2 := 0;
            else
              ep2 := TO_NUMBER(e2);
            end if;
            -- Epochs are non-null; compare them
            if ep1 < ep2 then return -1; end if;
            if ep1 > ep2 then return 1; end if;
            rc := rpmstrcmp(v1, v2);
            if rc != 0 then return rc; end if;
           return rpmstrcmp(r1, r2);
         END;

    END vercmp;

    FUNCTION vercmpCounter
    RETURN NUMBER
    IS
    BEGIN
        return vercmp_counter;
    END vercmpCounter;

    FUNCTION vercmpResetCounter
    RETURN NUMBER
    IS
        result NUMBER;
    BEGIN
        result := vercmp_counter;
        vercmp_counter := 0;
        return result;
    END vercmpResetCounter;
END rpm;
/

create or replace function
channel_name_join(sep_in in varchar2, ch_in in channel_name_t)
return varchar2
deterministic
is
	ret	varchar2(4000);
	i	binary_integer;
begin
	ret := '';
	i := ch_in.first;

	if i is null
	then
		return ret;
	end if;

	ret := ch_in(i);
	i := ch_in.next(i);

	while i is not null
	loop
		ret := ret || sep_in || ch_in(i);
		i := ch_in.next(i);
	end loop;

	return ret;
end;
/

CREATE OR REPLACE FUNCTION
ID_JOIN(sep_in IN VARCHAR2, ugi_in IN user_group_id_t)
RETURN VARCHAR2
deterministic
IS
	ret	VARCHAR2(4000);
	i	BINARY_INTEGER;
BEGIN
	ret := '';
	i := ugi_in.FIRST;

	IF i IS NULL
	THEN
		RETURN ret;
	END IF;

	ret := ugi_in(i);
	i := ugi_in.NEXT(i);

	WHILE i IS NOT NULL
	LOOP
		ret := ret || sep_in || ugi_in(i);
		i := ugi_in.NEXT(i);
	END LOOP;

	RETURN ret;
END;
/

CREATE OR REPLACE FUNCTION
LABEL_JOIN(sep_in IN VARCHAR2, ugi_in IN user_group_label_t)
RETURN VARCHAR2
deterministic
IS
	ret	VARCHAR2(4000);
	i	BINARY_INTEGER;
BEGIN
	ret := '';
	i := ugi_in.FIRST;

	IF i IS NULL
	THEN
		RETURN ret;
	END IF;

	ret := ugi_in(i);
	i := ugi_in.NEXT(i);

	WHILE i IS NOT NULL
	LOOP
		ret := ret || sep_in || ugi_in(i);
		i := ugi_in.NEXT(i);
	END LOOP;

	RETURN ret;
END;
/

CREATE OR REPLACE FUNCTION
LOOKUP_CHANNEL_ARCH(label_in IN VARCHAR2)
RETURN NUMBER
IS
	channel_arch_id		NUMBER;
BEGIN
	SELECT id
          INTO channel_arch_id
          FROM rhnChannelArch
         WHERE label = label_in;

	RETURN channel_arch_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            rhn_exception.raise_exception('channel_arch_not_found');
END;
/

CREATE OR REPLACE FUNCTION
LOOKUP_CLIENT_CAPABILITY(name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	cap_name_id		NUMBER;
BEGIN
	SELECT id
          INTO cap_name_id
          FROM rhnClientCapabilityName
         WHERE name = name_in;

	RETURN cap_name_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnClientCapabilityName (id, name)
                VALUES (rhn_client_capname_id_seq.nextval, name_in)
                RETURNING id INTO cap_name_id;
            COMMIT;
	RETURN cap_name_id;
END;
/

CREATE OR REPLACE FUNCTION
LOOKUP_CONFIG_FILENAME(name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id		NUMBER;
BEGIN
	SELECT id
          INTO name_id
          FROM rhnConfigFileName
         WHERE path = name_in;

	RETURN name_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnConfigFileName (id, path)
                VALUES (rhn_cfname_id_seq.nextval, name_in)
                RETURNING id INTO name_id;
            COMMIT;
	RETURN name_id;
END;
/

CREATE OR REPLACE FUNCTION
LOOKUP_CVE(name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id		NUMBER;
BEGIN
	SELECT id
          INTO name_id
          FROM rhnCve
         WHERE name = name_in;

	RETURN name_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnCve (id, name)
                VALUES (rhn_cve_id_seq.nextval, name_in)
                RETURNING id INTO name_id;
            COMMIT;
	RETURN name_id;
END LOOKUP_CVE;
/

CREATE OR REPLACE FUNCTION
LOOKUP_EVR(e_in IN VARCHAR2, v_in IN VARCHAR2, r_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	evr_id		NUMBER;
BEGIN
	SELECT id INTO evr_id
          FROM rhnPackageEvr
         WHERE ((epoch IS NULL and e_in IS NULL) OR (epoch = e_in))
           AND version = v_in AND release = r_in;

	RETURN evr_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnPackageEvr (id, epoch, version, release, evr)
            VALUES (rhn_pkg_evr_seq.nextval, e_in, v_in, r_in,
                EVR_T(e_in, v_in, r_in))
            RETURNING id INTO evr_id;
        COMMIT;
	RETURN evr_id;
END;
/

CREATE OR REPLACE FUNCTION
LOOKUP_PACKAGE_ARCH(label_in IN VARCHAR2)
RETURN NUMBER
IS
	package_arch_id		NUMBER;
BEGIN
   if label_in is null then
      return null;
   end if;

	SELECT id
          INTO package_arch_id
          FROM rhnPackageArch
         WHERE label = label_in;

	RETURN package_arch_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            rhn_exception.raise_exception('package_arch_not_found');
END;
/

CREATE OR REPLACE FUNCTION
LOOKUP_PACKAGE_CAPABILITY(name_in IN VARCHAR2,
    version_in IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id		NUMBER;
BEGIN
	IF version_in IS NULL THEN
		SELECT id
		  INTO name_id
		  FROM rhnPackageCapability
		 WHERE name = name_in
		   AND version IS NULL;
	ELSE
		SELECT id
		  INTO name_id
		  FROM rhnPackageCapability
		 WHERE name = name_in
		   AND version = version_in;
	END IF;
	RETURN name_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnPackageCapability (id, name, version)
                VALUES (rhn_pkg_capability_id_seq.nextval, name_in, version_in)
                RETURNING id INTO name_id;
            COMMIT;
	RETURN name_id;
END;
/

CREATE OR REPLACE FUNCTION
LOOKUP_PACKAGE_DELTA(n_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id         NUMBER;
BEGIN
	SELECT id INTO name_id
	  FROM rhnPackageDelta
	 WHERE label = n_in;

	RETURN name_id;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    INSERT INTO rhnPackageDelta (id, label)
	    VALUES (rhn_packagedelta_id_seq.nextval, n_in)
	    RETURNING id INTO name_id;
	COMMIT;
	RETURN name_id;
END;
/

CREATE OR REPLACE FUNCTION
LOOKUP_PACKAGE_NAME(name_in IN VARCHAR2, ignore_null in number := 0)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id		NUMBER;
BEGIN
	if ignore_null = 1 and name_in is null then
		return null;
	end if;

	SELECT id
          INTO name_id
          FROM rhnPackageName
         WHERE name = name_in;

	RETURN name_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnPackageName (id, name)
                VALUES (rhn_pkg_name_seq.nextval, name_in)
                RETURNING id INTO name_id;
            COMMIT;
	RETURN name_id;
END;
/

CREATE OR REPLACE FUNCTION
LOOKUP_SERVER_ARCH(label_in IN VARCHAR2)
RETURN NUMBER
IS
	server_arch_id		NUMBER;
BEGIN
	SELECT id
          INTO server_arch_id
          FROM rhnServerArch
         WHERE label = label_in;

	RETURN server_arch_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            rhn_exception.raise_exception('server_arch_not_found');
END;
/

CREATE OR REPLACE FUNCTION
lookup_snapshot_invalid_reason(label_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	snapshot_invalid_reason_id number;
BEGIN
	SELECT id
          INTO snapshot_invalid_reason_id
          FROM rhnSnapshotInvalidReason
         WHERE label = label_in;

	RETURN snapshot_invalid_reason_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            rhn_exception.raise_exception('invalid_snapshot_invalid_reason');
END;
/

CREATE OR REPLACE FUNCTION
LOOKUP_SOURCE_NAME(name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	source_id	NUMBER;
BEGIN
        select	id into source_id
        from	rhnSourceRPM
        where	name = name_in;

        RETURN source_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            insert into rhnSourceRPM(id, name)
                    values (rhn_sourcerpm_id_seq.nextval, name_in)
                    returning id into source_id;
            COMMIT;
            RETURN source_id;
END;
/

CREATE OR REPLACE FUNCTION
LOOKUP_TAG(org_id_in IN NUMBER, name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	tag_id     NUMBER;
BEGIN
        select id into tag_id
	  from rhnTag
	 where org_id = org_id_in
	   and name_id = lookup_tag_name(name_in);

        RETURN tag_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            insert into rhnTag(id, org_id, name_id)
                    values (rhn_tag_id_seq.nextval, org_id_in, lookup_tag_name(name_in))
                    returning id into tag_id;
            COMMIT;
            RETURN tag_id;
END;
/

CREATE OR REPLACE FUNCTION
LOOKUP_TAG_NAME(name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id     NUMBER;
BEGIN
        select id into name_id
	  from rhnTagName
	 where name = name_in;

        RETURN name_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            insert into rhnTagName(id, name)
                    values (rhn_tagname_id_seq.nextval, name_in)
                    returning id into name_id;
            COMMIT;
            RETURN name_id;
END;
/

CREATE OR REPLACE FUNCTION
LOOKUP_TRANSACTION_PACKAGE(o_in IN VARCHAR2, n_in IN VARCHAR2,
    e_in IN VARCHAR2, v_in IN VARCHAR2, r_in IN VARCHAR2, a_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
        o_id        NUMBER;
        n_id        NUMBER;
	e_id	    NUMBER;
        p_arch_id   NUMBER;
        tp_id       NUMBER;
BEGIN
	BEGIN
	    SELECT id
	      INTO o_id
	      FROM rhnTransactionOperation
	     WHERE label = o_in;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		rhn_exception.raise_exception('invalid_transaction_operation');
	END;

	SELECT LOOKUP_PACKAGE_NAME(n_in)
	  INTO n_id
	  FROM dual;

	SELECT LOOKUP_EVR(e_in, v_in, r_in)
	  INTO e_id
	  FROM dual;

	p_arch_id := NULL;
	IF a_in IS NOT NULL
	THEN
		SELECT LOOKUP_PACKAGE_ARCH(a_in)
		  INTO p_arch_id
		  FROM dual;
	END IF;

	SELECT id
	  INTO tp_id
	  FROM rhnTransactionPackage
	 WHERE operation = o_id
	   AND name_id = n_id
	   AND evr_id = e_id
	   AND (package_arch_id = p_arch_id OR (p_arch_id IS NULL AND package_arch_id IS NULL));
	RETURN tp_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
	    INSERT INTO rhnTransactionPackage
		(id, operation, name_id, evr_id, package_arch_id)
	    VALUES (rhn_transpack_id_seq.nextval, o_id, n_id, e_id, p_arch_id)
	    RETURNING id INTO tp_id;
	    COMMIT;
	    RETURN tp_id;
END;
/

CREATE OR REPLACE FUNCTION
NAME_JOIN(sep_in IN VARCHAR2, ugi_in IN user_group_name_t)
RETURN VARCHAR2
deterministic
IS
	ret	VARCHAR2(4000);
	i	BINARY_INTEGER;
BEGIN
	ret := '';
	i := ugi_in.FIRST;

	IF i IS NULL
	THEN
		RETURN ret;
	END IF;

	ret := ugi_in(i);
	i := ugi_in.NEXT(i);

	WHILE i IS NOT NULL
	LOOP
		ret := ret || sep_in || ugi_in(i);
		i := ugi_in.NEXT(i);
	END LOOP;

	RETURN ret;
END;
/

create or replace procedure  truncateCacheQueue as
begin
  execute immediate 'Truncate Table rhnOrgErrataCacheQueue';
end;
/

-- Bugzilla 453664
-- svn r175413
create or replace procedure
create_first_org
(
	name_in in varchar2,
	password_in in varchar2
) is
	ug_type			number;
	group_val		number;
begin
	insert into web_customer (
		id, name,
		oracle_customer_id, oracle_customer_number,
		customer_type
	) values (
		1, name_in,
		1, 1, 'B'
	);

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'org_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Organization Administrators',
		'Organization Administrators for Org ' || name_in || ' (1)',
		NULL, ug_type, 1
	);

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'org_applicant';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) VALues (
		group_val, 'Organization Applicants',
		'Organization Applicants for Org ' || name_in || ' (1)',
		NULL, ug_type, 1
	);

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'system_group_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'System Group Administrators',
		'System Group Administrators for Org ' || name_in || ' (1)',
		NULL, ug_type, 1
	);


	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'activation_key_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Activation Key Administrators',
		'Activation Key Administrators for Org ' || name_in || ' (1)',
		NULL, ug_type, 1
	);

	-- config admin is special; it gets created in
	-- rhn_entitlements.set_customer_provisioning instead.

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'channel_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Channel Administrators',
		'Channel Administrators for Org ' || name_in || ' (1)',
		NULL, ug_type, 1
	);

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'satellite_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Satellite Administrators',
		'Satellite Administrators for Org ' || name_in || ' (1)',
		NULL, ug_type, 1
	);


	-- if they need more than 16GB, they'll call us and we'll whip
	-- out a "can be null" patch, which we should do for next
	-- version anyway.  (I thought we did that for this version?)
	insert into rhnOrgQuota(
		org_id, total
	) values (
		1, 1024*1024*1024*16
	);


	-- there aren't any users yet, so we don't need to update
	-- rhnUserServerPerms
        insert into rhnServerGroup
		( id, name, description, max_members, group_type, org_id )
		select rhn_server_group_id_seq.nextval, sgt.name, sgt.name,
			0, sgt.id, 1
		from rhnServerGroupType sgt
		where sgt.label = 'sw_mgr_entitled';

end create_first_org;
/

create or replace procedure
create_new_org
(
	name_in      in varchar2,
	password_in  in varchar2,
	org_id_out   out number
) is
	ug_type			number;
	group_val		number;
	new_org_id              number;
begin

        select web_customer_id_seq.nextval into new_org_id from dual;

	insert into web_customer (
		id, name,
		oracle_customer_id, oracle_customer_number,
		customer_type
	) values (
		new_org_id, name_in,
		new_org_id, new_org_id, 'B'
	);

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'org_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Organization Administrators',
		'Organization Administrators for Org ' || name_in,
		NULL, ug_type, new_org_id
	);

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'org_applicant';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) VALues (
		group_val, 'Organization Applicants',
		'Organization Applicants for Org ' || name_in,
		NULL, ug_type, new_org_id
	);

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'system_group_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'System Group Administrators',
		'System Group Administrators for Org ' || name_in,
		NULL, ug_type, new_org_id
	);


	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'activation_key_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Activation Key Administrators',
		'Activation Key Administrators for Org ' || name_in,
		NULL, ug_type, new_org_id
	);

	-- config admin is special; it gets created in
	-- rhn_entitlements.set_customer_provisioning instead.

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'channel_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Channel Administrators',
		'Channel Administrators for Org ' || name_in,
		NULL, ug_type, new_org_id
	);

	-- there aren't any users yet, so we don't need to update
	-- rhnUserServerPerms
        insert into rhnServerGroup
		( id, name, description, max_members, group_type, org_id )
		select rhn_server_group_id_seq.nextval, sgt.name, sgt.name,
			0, sgt.id, new_org_id
		from rhnServerGroupType sgt
		where sgt.label = 'sw_mgr_entitled';

	org_id_out := new_org_id;

end create_new_org;
/


-- optimize indexes on rhnServerNeededPackageCache
-- svn r174738
drop index rhn_snpc_pid_eid_sid_idx;
create index rhn_snpc_pid_idx
        on rhnServerNeededPackageCache(package_id)
        parallel nologging;

drop index rhn_snpc_sid_pid_eid_idx;
create index rhn_snpc_sid_idx
        on rhnServerNeededPackageCache(server_id)
        parallel nologging;

drop index rhn_snpc_eid_sid_pid_idx;
create index rhn_snpc_eid_idx
        on rhnServerNeededPackageCache(errata_id)
        parallel nologging;

drop index rhn_snpc_oid_eid_sid_idx;
create index rhn_snpc_oid_idx
        on rhnServerNeededPackageCache(org_id)
        parallel nologging;

-- enable row movement on all tables
begin
  for i in (select * from user_tables) loop
    execute immediate 'alter table "' || i.table_name  || '" enable row movement';
  end loop;
end;

-- End of upgrade body



update rhnVersionInfo set evr_id = lookup_evr(null, '5.2.0', '7')
   where label = 'schema'
   and name_id = lookup_package_name('rhn-satellite-schema');

select   '*** Schema version is now ' || e.evr.as_vre_simple()
from  rhnPackageEVR e, rhnVersionInfo vi
where vi.evr_id = e.id
  and   vi.label = 'schema';

commit;


spool off;
exit;
