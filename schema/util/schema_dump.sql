-- Script to dump a brief summary of the schema for comparison
--
-- $Id$

column obj_type format a15
column obj_name format a30
column obj_data format a1000

select
    ' ' obj_type,
    ' ' obj_name,
    ' ' obj_data
from dual
UNION
select
    lower(object_type) obj_type,
    lower(object_name) obj_name,
    ' ' obj_data
from 
    user_objects 
where 
    object_type not in ('INDEX', 'VIEW', 'SYNONYM', 'TABLE', 'TRIGGER')
UNION
select 
    lower(object_type) obj_type,
    lower(object_name) obj_name,
    get_table_fields_list(object_name) obj_data
from
    user_objects
where
    object_type = 'TABLE'
UNION
select 
    lower(object_type) obj_type,
    lower(object_name) obj_name,
    get_index_fields_list(object_name) obj_data
from
    user_objects
where
    object_type = 'INDEX'
UNION
select
    'constraint' obj_type,
    lower(constraint_name) obj_name,
    lower(table_name) ||' '|| constraint_type ||' '|| lower(r_constraint_name) obj_data
from
    user_constraints
UNION
select
    'synonym' obj_type,
    lower(synonym_name) obj_name,
    lower(table_owner) ||'.'|| lower(table_name) obj_data
from
    user_synonyms
UNION
select
    'trigger' obj_type,
    lower(trigger_name) obj_name,
    lower(table_name) ||'('|| lower(triggering_event) || ', ' ||
        lower(trigger_type) || ')' obj_data
from
    user_triggers
UNION
select
    lower(object_type) obj_type, 
    lower(object_name) obj_name, 
    get_obj_deps_list(object_name) obj_data
from 
    user_objects 
where 
    object_type = 'VIEW' 
order by obj_type, obj_name;

