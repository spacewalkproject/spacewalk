set linesize 80;
column explain_id format a2
column explain_parent_id format a2
column explain_operation format a16
column explain_options format a16
column explain_object_name format a30
select
	to_char(id) explain_id,
	to_char(parent_id) explain_parent_id,
	operation explain_operation,
	options explain_options,
	object_name explain_object_name
from
	plan_table
where
	statement_id = '&foo'
order by to_number(explain_parent_id),to_number(explain_id) asc
/
