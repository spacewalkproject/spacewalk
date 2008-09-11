--
-- $Id$
--
-- this finds foreign key constraints with "no action"
--

select	cons1.table_name, cons1.constraint_name
from	user_constraints cons1,
	user_constraints cons2
where	cons2.table_name = upper('&table_name_in')
	and cons1.r_constraint_name = cons2.constraint_name
	and cons1.delete_rule = 'NO ACTION'
/

--
-- $Log$
-- Revision 1.1  2004/03/15 16:39:57  pjones
-- bugzilla: none -- utility to find foreign key constraints that might need
-- a cascade
--
