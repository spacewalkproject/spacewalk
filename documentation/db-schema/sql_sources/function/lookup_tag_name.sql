-- created by Oraschemadoc Fri Mar  2 05:58:12 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_TAG_NAME" (name_in in varchar2)
return number
is
	pragma autonomous_transaction;
	name_id     number;
begin
    select id
      into name_id
	  from rhnTagName
	 where name = name_in;

    return name_id;
exception when no_data_found then
    begin
        name_id := insert_tag_name(name_in);
    exception when dup_val_on_index then
        select id
          into name_id
    	  from rhnTagName
    	 where name = name_in;
    end;
    return name_id;
end;
 
/
