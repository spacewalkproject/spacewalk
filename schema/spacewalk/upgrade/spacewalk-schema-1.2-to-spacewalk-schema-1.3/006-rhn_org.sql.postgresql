-- oracle equivalent source sha1 3f169746e617ed37ebfd0feed44be455ecd33da8
--
-- Copyright (c) 2011--2012 Red Hat, Inc.

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_org,' || setting where name = 'search_path';

drop function find_server_group_by_type(org_id_in NUMERIC, group_label_in VARCHAR);

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_org')+1) ) where name = 'search_path';
