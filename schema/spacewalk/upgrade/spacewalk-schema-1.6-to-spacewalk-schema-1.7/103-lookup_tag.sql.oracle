create or replace function insert_tag(org_id_in in number, name_in in varchar2)
return number
is
    pragma autonomous_transaction;
    tag_id  number;
begin
    insert into rhnTag(id, org_id, name_id)
    values (rhn_tag_id_seq.nextval, org_id_in, lookup_tag_name(name_in)) returning id into tag_id;
    commit;
    return tag_id;
end;
/
show errors

create or replace function
lookup_tag(org_id_in in number, name_in in varchar2)
return number
is
    pragma autonomous_transaction;
    tag_id  number;
begin
    select id
      into tag_id
      from rhnTag
     where org_id = org_id_in and
           name_id = lookup_tag_name(name_in);

    return tag_id;
exception when no_data_found then
    begin
        tag_id := insert_tag(org_id_in, name_in);
    exception when dup_val_on_index then
        select id
          into tag_id
          from rhnTag
         where org_id = org_id_in and
               name_id = lookup_tag_name(name_in);
    end;
    return tag_id;
end;
/
show errors
