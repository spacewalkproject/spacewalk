--
-- $Id$
--
-- this finds foreign keys to a table which aren't supported by an index.
-- this is important for deletes -- it means the table will be locked
-- while refcounts are validated.
--
-- this doesn't always with compound foreign keys, but we barely use
-- them anywhere.

column table_name format a20
column column_name format a20
column column_position format 9999
select	cons1.table_name,
	conscol.column_name
from	all_constraints cons1,
	all_cons_columns conscol,
	all_cons_columns conscol2,
	all_constraints cons2
where	cons2.table_name = upper('&table_name_in')
	and conscol2.constraint_name = cons2.constraint_name
	and conscol2.column_name = upper('&column_name_in')
	and cons1.r_constraint_name = cons2.constraint_name
	and cons1.constraint_type = 'R'
	and cons1.constraint_name = conscol.constraint_name
	and conscol.position = 1
/

-- $Log$
-- Revision 1.1  2004/03/05 16:34:00  pjones
-- bugzilla: none -- utility to find references to a column
--
-- Revision 1.2  2004/01/27 20:54:25  pjones
-- bugzilla: none -- make this more useful; now finds anything without the
-- first column of the index being correct, so we can use it (somewhat) with
-- multicolumn foreign keys
--
-- Revision 1.1  2002/11/22 21:25:02  pjones
-- this finds foreign keys that aren't properly referenced by an index
-- if deletes are slow, this often finds the culprit
--
-- Revision 1.1  2002/11/22 17:02:53  pjones
-- find cascading delete triggers
--
