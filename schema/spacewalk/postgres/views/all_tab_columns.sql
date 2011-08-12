-- oracle equivalent source none

create or replace view all_tab_columns
as
select
        table_name              as table_name,
        column_name             as column_name,
        ordinal_position        as column_id,
        data_type               as data_type,
        numeric_precision       as data_precision,
        substr(is_nullable,1,1) as nullable
from information_schema.columns;
