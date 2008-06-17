column index_name format a30
column column_name format a30
select
	index_name,column_name
from
	all_ind_columns
where
	table_name = upper('&table')
order by
	index_name,column_position
/
