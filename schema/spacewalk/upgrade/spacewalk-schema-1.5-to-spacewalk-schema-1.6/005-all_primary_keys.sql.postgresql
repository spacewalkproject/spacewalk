-- oracle equivalent source sha1 745701c8146c848eb2a3d1b18fd93d4332453103

create or replace view all_primary_keys as
select
        ts.table_name              as table_name,
        ts.constraint_name         as constraint_name,
        ccu.column_name            as column_name
  from information_schema.table_constraints ts
  join information_schema.constraint_column_usage ccu
    on ts.table_name = ccu.table_name
   and ts.table_schema = ccu.table_schema
   and ts.constraint_name = ccu.constraint_name
 where ts.constraint_type = 'PRIMARY KEY';
