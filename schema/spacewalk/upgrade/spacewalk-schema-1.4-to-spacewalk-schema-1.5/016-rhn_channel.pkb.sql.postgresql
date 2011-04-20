-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

--update pg_setting
update pg_settings set setting = 'rhn_channel,' || setting where name = 'search_path';

    CREATE OR REPLACE FUNCTION available_fve_chan_subs(channel_id_in IN NUMERIC,
                                          org_id_in IN NUMERIC)
    RETURNS NUMERIC
    AS $$
    declare
            channel_family_id_val NUMERIC;
    BEGIN
        SELECT channel_family_id INTO STRICT channel_family_id_val
            FROM rhnChannelFamilyMembers
            WHERE channel_id = channel_id_in;

            RETURN rhn_channel.available_fve_family_subs(
                           channel_family_id_val, org_id_in);
    END$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_channel')+1) ) where name = 'search_path';
