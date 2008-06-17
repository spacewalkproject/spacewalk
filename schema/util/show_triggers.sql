column tname format a30
column ttype format a20

select
	ut.trigger_name	tname,
	ut.trigger_type	ttype
from 
	user_triggers ut
where
	ut.table_name = upper('&table')
order by
	tname,ttype
/
