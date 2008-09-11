--
-- $Id$
--

create or replace function
lookup_sg_type(label_in in varchar2)
return number
deterministic
is
	server_group_type_id number;
begin
	select	id
	into	server_group_type_id
	from	rhnServerGroupType sgt
	where	label = label_in;

	return server_group_type_id;
exception
        when no_data_found then
            rhn_exception.raise_exception('invalid_server_group');
end;
/
show errors

--
-- $Log$
-- Revision 1.1  2004/02/19 22:19:29  pjones
-- bugzilla: 115896 -- don't let servers subscribe to services for which
-- their server arch is not compatible
--
