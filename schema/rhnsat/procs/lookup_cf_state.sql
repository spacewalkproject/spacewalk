--
-- $Id$
--

create or replace function
lookup_cf_state(
	label_in in varchar2
) return number deterministic
is
	state_id number;
begin
	select	id
	into	state_id
	from	rhnConfigFileState
	where	label = label_in;

	return state_id;
end;
/
show errors

--
-- $Log$
-- Revision 1.1  2003/11/09 17:37:27  pjones
-- bugzilla: 109083 -- lookup the state of a config file
--
