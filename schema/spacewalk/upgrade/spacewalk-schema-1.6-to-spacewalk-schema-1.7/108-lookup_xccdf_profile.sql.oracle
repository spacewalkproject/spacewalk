create or replace function
insert_xccdf_profile(identifier_in in varchar2, title_in in varchar2)
return number
is
    pragma autonomous_transaction;
    profile_id  number;
begin
    insert into rhnXccdfProfile (id, identifier, title)
    values (rhn_xccdf_profile_id_seq.nextval, identifier_in, title_in) returning id into profile_id;
    commit;
    return profile_id;
end;
/
show errors

create or replace function
lookup_xccdf_profile(identifier_in in varchar2, title_in in varchar2)
return number
is
    profile_id  number;
begin
    select id
      into profile_id
      from rhnXccdfProfile
     where identifier = identifier_in and title = title_in;
    return profile_id;
exception when no_data_found then
    begin
        profile_id := insert_xccdf_profile(identifier_in, title_in);
    exception when dup_val_on_index then
        select id
          into profile_id
          from rhnXccdfProfile
         where identifier = identifier_in and title = title_in;
    end;
    return profile_id;
end lookup_xccdf_profile;
/
show errors
