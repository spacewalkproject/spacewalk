--
-- $Id$
-- EXCLUDE: all
--

create or replace function
lookup_hwpropval(value_in in varchar2)
return number
deterministic
is
	pragma autonomous_transaction;
	value_id number;
	our_csum number;
begin
	our_csum := adler32(value_in);
	select  id
	into    value_id
	from    rhnHardwarePropValue
	where   csum = our_csum;
										
	return value_id;
exception
	when no_data_found then
		insert into rhnHardwarePropValue (id, value, csum)
			values (rhn_hwpropval_id_seq.nextval,
				value_in, our_csum)
			returning id
			into value_id;
		commit;
		return value_id;
end;
/
show errors

-- $Log$
-- Revision 1.3  2003/08/20 16:39:54  pjones
-- bugzilla: none
--
-- disable hw here too
--
-- Revision 1.2  2003/07/01 23:36:47  misa
-- bugzilla: 84125  Typo
--
-- Revision 1.1  2003/06/19 22:25:17  pjones
-- bugzilla: 84125 -- add the lookup functions, fix build
--
