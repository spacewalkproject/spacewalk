-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_entitlements,' || setting where name = 'search_path';

create or replace function assign_channel_entitlement(
        channel_family_label_in in varchar,
        from_org_id_in in numeric,
        to_org_id_in in numeric,
        quantity_in in numeric,
        flex_in in numeric
    ) returns void
as $$
    declare
        from_org_prev_ent_count numeric;
        from_org_prev_ent_count_flex numeric;
        new_ent_count numeric;
        new_ent_count_flex numeric;
        to_org_prev_ent_count numeric;
        to_org_prev_ent_count_flex numeric;
        new_quantity numeric;
        new_flex numeric;
        cfam_id       numeric;
    begin

            select max_members
            into from_org_prev_ent_count
            from rhnChannelFamily cf,
                 rhnPrivateChannelFamily pcf
            where pcf.org_id = from_org_id_in
              and pcf.channel_family_id = cf.id
              and cf.label = channel_family_label_in;

            if not found then
                perform rhn_exception.raise_exception(
                              'not_enough_entitlements_in_base_org');
            end if;

            select max_members
            into to_org_prev_ent_count
            from rhnChannelFamily cf,
                 rhnPrivateChannelFamily pcf
            where pcf.org_id = to_org_id_in
              and pcf.channel_family_id = cf.id
              and cf.label = channel_family_label_in;

            if not found then
                to_org_prev_ent_count := 0;
            end if;

            select fve_max_members
            into from_org_prev_ent_count_flex
            from rhnChannelFamily cf,
                rhnPrivateChannelFamily pcf
            where pcf.org_id = from_org_id_in
              and pcf.channel_family_id = cf.id
              and cf.label = channel_family_label_in;

            if not found then
                perform rhn_exception.raise_exception(
                              'not_enough_flex_entitlements_in_base_org');
            end if;

            select fve_max_members
            into to_org_prev_ent_count_flex
            from rhnChannelFamily cf,
                 rhnPrivateChannelFamily pcf
            where pcf.org_id = to_org_id_in
              and pcf.channel_family_id = cf.id
              and cf.label = channel_family_label_in;

            if not found then
                to_org_prev_ent_count_flex := 0;
            end if;

            select id
            into cfam_id
            from rhnChannelFamily
            where label = channel_family_label_in;

            if not found then
                perform rhn_exception.raise_exception(
                              'invalid_channel_family');
            end if;

        new_ent_count := from_org_prev_ent_count - quantity_in;
        new_ent_count_flex := from_org_prev_ent_count_flex - flex_in;

        if from_org_prev_ent_count > new_ent_count then
            new_quantity := to_org_prev_ent_count + quantity_in;
        end if;

        if from_org_prev_ent_count_flex >= new_ent_count_flex then
            new_flex := to_org_prev_ent_count_flex + flex_in;
        end if;

        if new_ent_count < 0 then
            perform rhn_exception.raise_exception(
                          'not_enough_entitlements_in_base_org');
        end if;

        if new_ent_count_flex < 0 then
            perform rhn_exception.raise_exception(
                          'not_enough_flex_entitlements_in_base_org');
        end if;



        perform rhn_entitlements.set_family_count(from_org_id_in,
                                          cfam_id,
                                          new_ent_count,
                                          new_ent_count_flex);

        perform rhn_entitlements.set_family_count(to_org_id_in,
                                          cfam_id,
                                          new_quantity,
                                          new_flex);

    end$$
language plpgsql;

drop function assign_channel_entitlement(
    channel_family_label_in varchar,
    from_org_id_in numeric,
    to_org_id_in numeric,
    quantity_in numeric
    );

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_entitlements')+1) ) where name = 'search_path';
