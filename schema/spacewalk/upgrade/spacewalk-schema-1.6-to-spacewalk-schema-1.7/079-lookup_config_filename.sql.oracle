create or replace function
insert_config_filename(name_in in varchar2)
return number
is
    pragma autonomous_transaction;
    name_id number;
begin
    insert into rhnConfigFileName (id, path)
    values (rhn_cfname_id_seq.nextval, name_in) returning id into name_id;
    commit;

    return name_id;
end;
/

create or replace function
lookup_config_filename(name_in in varchar2)
return number
is
    pragma autonomous_transaction;
    name_id		number;
begin
    select id
      into name_id
      from rhnConfigFileName
     where path = name_in;

    return name_id;
exception when no_data_found then
    begin
        select insert_config_filename(name_in) into name_id from dual;
    exception when dup_val_on_index then
        select id
          into name_id
          from rhnConfigFileName
         where path = name_in;
    end;

	return name_id;
end;
/
show errors
