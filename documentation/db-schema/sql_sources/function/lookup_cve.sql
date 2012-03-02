-- created by Oraschemadoc Fri Mar  2 05:58:12 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_CVE" (name_in in varchar2)
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
