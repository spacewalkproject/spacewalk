-- oracle equivalent source sha1 82ad2287cb726f13fa01da60a48940d2eac9a369

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_quota,' || setting where name = 'search_path';

drop function get_org_for_config_content ( config_content_id_in in numeric );

drop function set_org_quota_total ( org_id_in in numeric, total_in in numeric );

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_quota')+1) ) where name = 'search_path';
