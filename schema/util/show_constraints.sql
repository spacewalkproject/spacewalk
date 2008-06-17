column cname format a30
column ctype format a6
column crule format a15
column clname format a20
column clpos format 99

select
	uc.constraint_name	cname,
	uc.constraint_type	ctype,
	uc.delete_rule		crule,
	ucc.column_name		clname,
	ucc.position		clpos
from 
	all_constraints uc,
	all_cons_columns ucc
where
	ucc.constraint_name = uc.constraint_name
	and uc.table_name = upper('&table')
order by
	cname,clpos,ctype,clname
/
