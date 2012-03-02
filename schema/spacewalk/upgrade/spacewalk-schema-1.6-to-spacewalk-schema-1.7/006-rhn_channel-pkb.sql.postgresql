-- oracle equivalent source sha1 4e778553460cc1f03a7dcbb98c8e27ff98320642


--update pg_setting
update pg_settings set setting = 'rhn_channel,' || setting where name = 'search_path';

    drop function refresh_newest_package(channel_id_in in numeric,
                                      caller_in in varchar);

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


-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_channel')+1) ) where name = 'search_path';
