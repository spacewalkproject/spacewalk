create or replace function insert_cve(name_in in varchar2)
return number
is
    pragma autonomous_transaction;
    name_id     number;
begin
    insert into rhnCVE (id, name)
    values (rhn_cve_id_seq.nextval, name_in) returning id into name_id;
    commit;
    return name_id;
end;
/
show errors

create or replace function
lookup_cve(name_in in varchar2)
return number
is
    name_id		number;
begin
    select id
      into name_id
      from rhnCVE
     where name = name_in;

    return name_id;
exception when no_data_found then
    begin
        name_id := insert_cve(name_in);
    exception when dup_val_on_index then
        select id
          into name_id
          from rhnCVE
         where name = name_in;
    end;
    return name_id;
end;
/
show errors
