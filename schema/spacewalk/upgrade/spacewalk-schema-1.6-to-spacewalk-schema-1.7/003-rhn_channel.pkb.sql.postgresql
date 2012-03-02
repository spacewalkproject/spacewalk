-- oracle equivalent source sha1 1c0f62512237548004ff02a21dcd5c35a02fd505

--update pg_setting
update pg_settings set setting = 'rhn_channel,' || setting where name = 'search_path';


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
           and CFM.channel_id = channel_id_in
           and (CFP.max_members > 0 or CFP.max_members is null or CFP.fve_max_members > 0 or CFP.fve_max_members is null or CFP.org_id = 1) )
        then
          return 1;
        else
          return 0;
        end if;
    end$$ language plpgsql;


-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_channel')+1) ) where name = 'search_path';
