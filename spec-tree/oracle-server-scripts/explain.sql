-- Show up what's going on in the last query that was explain plan-ed

select
    to_char(parent_id) id1,
    to_char(id) id2,
    lpad(' ',2*(LEVEL-1)) || operation || '  ' || options || '  ' || object_name
    explain_operation
from
    plan_table
start with id = 1 and statement_id = '&st_id'
connect by prior id = parent_id and statement_id = '&st_id';

