--
-- $Id$
--

create or replace function
lookup_arch_type(label_in in varchar2)
return number
deterministic
is
	arch_type_id number;
begin
	select id into arch_type_id from rhnArchType where label = label_in;
	return arch_type_id;
exception
	when no_data_found then
		rhn_exception.raise_exception('arch_type_not_found');
end;
/
show errors

-- $Log$
-- Revision 1.1  2004/02/05 17:33:12  pjones
-- bugzilla: 115009 -- rhnArchType is new, and has changes to go with it
--
-- Revision 1.1  2002/11/13 23:16:18  pjones
-- lookup_*_arch()
--
