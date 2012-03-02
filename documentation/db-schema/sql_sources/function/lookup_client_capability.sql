-- created by Oraschemadoc Fri Mar  2 05:58:12 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_CLIENT_CAPABILITY" (name_in in varchar2)
return number
is
    cap_name_id		number;
begin
    select id
      into cap_name_id
      from rhnClientCapabilityName
     where name = name_in;

    return cap_name_id;
exception when no_data_found then
    begin
        select insert_client_capability(name_in) into cap_name_id from dual;
    exception when dup_val_on_index then
        select id
          into cap_name_id
          from rhnClientCapabilityName
         where name = name_in;
    end;
	return cap_name_id;
end;
 
/
