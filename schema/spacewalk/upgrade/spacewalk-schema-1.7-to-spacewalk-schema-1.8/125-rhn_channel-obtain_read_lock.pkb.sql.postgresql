-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

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

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_channel')+1) ) where name = 'search_path';
