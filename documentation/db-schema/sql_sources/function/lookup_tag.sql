-- created by Oraschemadoc Fri Mar  2 05:58:12 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_TAG" (org_id_in in number, name_in in varchar2)
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
