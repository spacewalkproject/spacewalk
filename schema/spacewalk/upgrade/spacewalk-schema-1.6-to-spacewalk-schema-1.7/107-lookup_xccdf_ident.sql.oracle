create or replace function insert_xccdf_ident_system(system_in varchar2)
return number
is
    pragma autonomous_transaction;
    ident_sys_id number;
begin
    insert into rhnXccdfIdentSystem (id, system)
    values (rhn_xccdf_identsytem_id_seq.nextval, system_in) returning id into ident_sys_id;
    commit;
    return ident_sys_id;
end;
/
show errors

create or replace function insert_xccdf_ident(ident_sys_id number, identifier_in in varchar2)
return number
is
    pragma autonomous_transaction;
    xccdf_ident_id  number;
begin
    insert into rhnXccdfIdent (id, identsystem_id, identifier)
    values (rhn_xccdf_ident_id_seq.nextval, ident_sys_id, identifier_in) returning id into xccdf_ident_id;
    commit;
    return xccdf_ident_id;
end;
/

create or replace function
lookup_xccdf_ident(system_in in varchar2, identifier_in in varchar2)
return number
is
    pragma autonomous_transaction;
    xccdf_ident_id number;
    ident_sys_id number;
begin
    begin
        select id
          into ident_sys_id
          from rhnXccdfIdentSystem
         where system = system_in;
    exception when no_data_found then
        begin
            ident_sys_id := insert_xccdf_ident_system(system_in);
        exception when dup_val_on_index then
            select id
              into ident_sys_id
              from rhnXccdfIdentSystem
             where system = system_in;
        end;
    end;

    select id
      into xccdf_ident_id
      from rhnXccdfIdent
     where identsystem_id = ident_sys_id and identifier = identifier_in;
    return xccdf_ident_id;
exception when no_data_found then
    begin
        xccdf_ident_id := insert_xccdf_ident(ident_sys_id, identifier_in);
    exception when dup_val_on_index then
        select id
          into xccdf_ident_id
          from rhnXccdfIdent
         where identsystem_id = ident_sys_id and identifier = identifier_in;
    end;
    return xccdf_ident_id;
end lookup_xccdf_ident;
/
show errors
