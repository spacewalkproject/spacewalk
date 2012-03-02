-- created by Oraschemadoc Fri Mar  2 05:58:11 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."INSERT_TAG" (org_id_in in number, name_in in varchar2)
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
