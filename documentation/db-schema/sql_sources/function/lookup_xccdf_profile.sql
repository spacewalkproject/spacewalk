-- created by Oraschemadoc Fri Mar  2 05:58:13 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_XCCDF_PROFILE" (identifier_in in varchar2, title_in in varchar2)
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
