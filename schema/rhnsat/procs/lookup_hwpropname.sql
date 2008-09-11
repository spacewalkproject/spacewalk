--
-- $Id$
-- EXCLUDE: all
--

create or replace function
lookup_hwpropname(name_in in varchar2)
return number
deterministic
is
	pragma autonomous_transaction;
	name_id number;
begin
	select  id
	into    name_id
	from    rhnHardwarePropName
	where   name = name_in;

	return name_id;
exception
	when no_data_found then
		insert into rhnHardwarePropName (id, name)
			values (rhn_hwpropname_id_seq.nextval, name_in)
			returning id
			into name_id;
		commit;
		return name_id;
end;
/
show errors

-- $Log$
-- Revision 1.2  2003/08/20 16:39:54  pjones
-- bugzilla: none
--
-- disable hw here too
--
-- Revision 1.1  2003/06/19 22:25:17  pjones
-- bugzilla: 84125 -- add the lookup functions, fix build
--
