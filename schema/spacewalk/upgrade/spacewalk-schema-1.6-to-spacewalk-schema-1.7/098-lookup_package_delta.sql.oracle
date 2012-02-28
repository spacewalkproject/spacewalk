create or replace function insert_package_delta(n_in in varchar2)
return number
is
    pragma autonomous_transaction;
    name_id     number;
begin
    insert into rhnPackageDelta(id, label)
    values (rhn_packagedelta_id_seq.nextval, n_in) returning id into name_id;
    commit;
    return name_id;
end;
/

create or replace function
lookup_package_delta(n_in in varchar2)
return number
is
	name_id         number;
begin
    select id
      into name_id
      from rhnpackagedelta
     where label = n_in;

	return name_id;
exception when no_data_found then
    begin
        name_id := insert_package_delta(n_in);
    exception when dup_val_on_index then
        select id
          into name_id
          from rhnPackageDelta
         where label = n_in;
    end;
	return name_id;
end;
/
show errors
