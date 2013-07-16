-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

create temporary table store_searchpath as select setting from pg_settings where name = 'search_path';

\i /usr/share/pgsql/contrib/dblink.sql

update pg_settings set setting = (select setting from store_searchpath) where name = 'search_path';
drop table store_searchpath;
