-- oracle equivalent source sha1 4b217f541831bee16b1c9b4b8597ea488b038e69

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_user,' || setting where name = 'search_path';

drop function find_mailable_address(user_id_in in numeric);

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_user')+1) ) where name = 'search_path';
