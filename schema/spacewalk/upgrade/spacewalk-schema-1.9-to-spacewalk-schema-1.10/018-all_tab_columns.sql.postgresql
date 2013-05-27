-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

drop view all_tab_columns;

create or replace view all_tab_columns
as
select
        table_name              as table_name,
        column_name             as column_name,
        ordinal_position        as column_id,
        data_type               as data_type,
        numeric_precision       as data_precision,
        character_maximum_length as data_length,
        substr(is_nullable,1,1) as nullable
from information_schema.columns;
