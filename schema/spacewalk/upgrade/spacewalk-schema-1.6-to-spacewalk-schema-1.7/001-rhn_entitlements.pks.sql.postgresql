-- oracle equivalent source sha1 cf474e5f4f51e7de9261116cf837ed9bbf2f2c2c

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_entitlements,' || setting where name = 'search_path';

    drop function set_group_count (
               customer_id_in in numeric,      -- customer_id
               type_in in char,                        -- 'U' or 'S'
               group_type_in in numeric,       -- rhn[User|Server]GroupType.id
               quantity_in in numeric,         -- quantity
               update_family_countsYN in numeric     -- call update_family_counts inside
    );

    drop function prune_group (
         group_id_in in numeric,
         type_in in char,
         quantity_in in numeric,
         update_family_countsYN in numeric
    );

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_entitlements')+1) ) where name = 'search_path';
