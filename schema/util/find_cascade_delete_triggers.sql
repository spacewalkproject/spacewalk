--
-- $Id$
--
-- this finds triggers for tables with on-delete-cascade foreign keys
--

select	trig.table_name,
	trig.trigger_name
from	user_triggers trig,
	user_constraints cons1,
	user_constraints cons2
where	cons2.table_name = upper('&table_name_in')
	and cons1.r_constraint_name = cons2.constraint_name
	and cons1.delete_rule = 'CASCADE'
	and cons1.table_name = trig.table_name
	and trig.triggering_event = 'DELETE'
/

-- $Log$
-- Revision 1.1  2002/11/22 17:02:53  pjones
-- find cascading delete triggers
--
