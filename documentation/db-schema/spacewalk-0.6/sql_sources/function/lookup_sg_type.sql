-- created by Oraschemadoc Mon Aug 31 10:54:42 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "MIM1"."LOOKUP_SG_TYPE" (label_in in varchar2)
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
