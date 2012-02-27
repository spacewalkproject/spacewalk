create or replace function insert_client_capability(name_in varchar2)
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

create or replace function
lookup_client_capability(name_in in varchar2)
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
show errors
