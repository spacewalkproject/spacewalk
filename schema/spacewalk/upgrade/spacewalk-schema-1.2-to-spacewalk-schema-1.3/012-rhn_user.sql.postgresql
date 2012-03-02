-- oracle equivalent source sha1 687d4c207df2ef725bf651663e1d5bc606ea53b2
--
-- Copyright (c) 2011--2012 Red Hat, Inc.

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_user,' || setting where name = 'search_path';

drop function add_users_to_usergroups(user_id_in in numeric);
drop function remove_users_from_servergroups(user_id_in in numeric);

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_user')+1) ) where name = 'search_path';
