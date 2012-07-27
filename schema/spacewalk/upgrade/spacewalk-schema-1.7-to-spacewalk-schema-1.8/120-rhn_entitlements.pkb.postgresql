-- oracle equivalent source sha1 59c6bda096f0db5a00764d92dea6e6101656cfbd
--
-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_entitlements,' || setting where name = 'search_path';

    -- this desperately needs to be table driven.
    create or replace function modify_org_service (
        org_id_in in numeric,
        service_label_in in varchar,
        enable_in in char
    ) returns void
as $$
    declare
        roles_to_process varchar[];
        roles cursor(role_label_in varchar) for
            select  label, id
            from    rhnUserGroupType
            where   label = role_label_in;
        org_roles cursor(role_label_in varchar) for
            select  1
            from    rhnUserGroup ug,
                    rhnUserGroupType ugt
            where   ugt.label = role_label_in
                and ug.org_id = org_id_in
                and ugt.id = ug.group_type;

        ents_to_process varchar[];
        ents cursor(ent_label_in varchar) for
            select  label, id
            from    rhnOrgEntitlementType
            where   label = ent_label_in;
        org_ents cursor(ent_label_in varchar) for
            select  1
            from    rhnOrgEntitlements oe,
                    rhnOrgEntitlementType oet
            where   oet.label = ent_label_in
                and oe.org_id = org_id_in
                and oet.id = oe.entitlement_id;
        create_row char(1);
    begin
        ents_to_process := '{}';
        roles_to_process := '{}';
        -- a bit kludgy, but only for 3.4 really.  Certainly no
        -- worse than the old code...
        if service_label_in = 'enterprise' or
           service_label_in = 'management' then
            ents_to_process := array_append(ents_to_process, 'sw_mgr_enterprise');

            roles_to_process := array_append(roles_to_process, 'org_admin');

            roles_to_process := array_append(roles_to_process, 'system_group_admin');

            roles_to_process := array_append(roles_to_process, 'activation_key_admin');
        elsif service_label_in = 'provisioning' then
            ents_to_process := array_append(ents_to_process, 'rhn_provisioning');

            roles_to_process := array_append(roles_to_process, 'system_group_admin');

            roles_to_process := array_append(roles_to_process, 'activation_key_admin');

            roles_to_process := array_append(roles_to_process, 'config_admin');
            -- another nasty special case...
            if enable_in = 'Y' then
                ents_to_process := array_append(ents_to_process, 'sw_mgr_enterprise');
            end if;
        elsif service_label_in = 'monitoring' then
            ents_to_process := array_append(ents_to_process, 'rhn_monitor');

            roles_to_process := array_append(roles_to_process, 'monitoring_admin');
        elsif service_label_in = 'virtualization' then
            ents_to_process := array_append(ents_to_process, 'rhn_virtualization');

            roles_to_process := array_append(roles_to_process, 'config_admin');
        elsif service_label_in = 'virtualization_platform' then
            ents_to_process := array_append(ents_to_process, 'rhn_virtualization_platform');
            roles_to_process := array_append(roles_to_process, 'config_admin');
    elsif service_label_in = 'nonlinux' then
            ents_to_process := array_append(ents_to_process, 'rhn_nonlinux');
            roles_to_process := array_append(roles_to_process, 'config_admin');
        end if;

        if enable_in = 'Y' then
            for i in 1..array_upper(ents_to_process, 1) loop
                for ent in ents(ents_to_process[i]) loop
                    create_row := 'Y';
                    for oe in org_ents(ent.label) loop
                        create_row := 'N';
                    end loop;
                    if create_row = 'Y' then
                        insert into rhnOrgEntitlements(org_id, entitlement_id)
                            values (org_id_in, ent.id);
                    end if;
                end loop;
            end loop;
            for i in 1..array_upper(roles_to_process, 1) loop
                for role in roles(roles_to_process[i]) loop
                    create_row := 'Y';
                    for o_r in org_roles(role.label) loop
                        create_row := 'N';
                    end loop;
                    if create_row = 'Y' then
                        insert into rhnUserGroup(
                                id, name, description, current_members,
                                group_type, org_id
                            ) (
                                select  nextval('rhn_user_group_id_seq'),
                                        ugt.name || 's',
                                        ugt.name || 's for Org ' ||
                                            o.name || ' ('|| o.id ||')',
                                        0, ugt.id, o.id
                                from    rhnUserGroupType ugt,
                                        web_customer o
                                where   o.id = org_id_in
                                    and ugt.id = role.id
                            );
                    end if;
                end loop;
            end loop;
        else
            for i in 1..coalesce(array_upper(ents_to_process, 1), 0) loop
                for ent in ents(ents_to_process[i]) loop
                    delete from rhnOrgEntitlements
                     where org_id = org_id_in
                       and entitlement_id = ent.id;
                end loop;
            end loop;
        end if;
    end$$
language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_entitlements')+1) ) where name = 'search_path';
