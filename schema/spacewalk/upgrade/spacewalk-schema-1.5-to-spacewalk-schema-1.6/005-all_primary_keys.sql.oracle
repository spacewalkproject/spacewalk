create or replace view all_primary_keys as
select
       ac.table_name,
       ac.constraint_name,
       acc.column_name
  from all_constraints ac
  join all_cons_columns acc
    on ac.constraint_name = acc.constraint_name
   and ac.owner = acc.owner
 where ac.constraint_type = 'P';
