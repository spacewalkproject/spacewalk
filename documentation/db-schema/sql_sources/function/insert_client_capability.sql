-- created by Oraschemadoc Fri Mar  2 05:58:11 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."INSERT_CLIENT_CAPABILITY" (name_in varchar2)
return number
is
    pragma autonomous_transaction;
    cap_name_id     number;
begin
    insert into rhnClientCapabilityName (id, name)
    values (rhn_client_capname_id_seq.nextval, name_in) returning id into cap_name_id;

    commit;
    return cap_name_id;
end;
 
/
