-- Show up what's going up in a query
--
-- $Id$

set linesize 300
-- empty lines are annoying for this output
set pagesize 0

set wrap off
column explain_id format a2
column explain_parent_id format a2
column explain_operation format a200

set heading off;

variable stmt_id varchar2(30);
exec :stmt_id := '&name';

select
    to_char(parent_id) explain_parent_id,
    to_char(id) explain_id,
    lpad(' ',2*(LEVEL-1)) || operation || '  ' || options || '  ' || object_name 
    explain_operation
from 
    plan_table 
start with id = 0 and statement_id = :stmt_id
connect by prior id = parent_id and statement_id = :stmt_id
/


