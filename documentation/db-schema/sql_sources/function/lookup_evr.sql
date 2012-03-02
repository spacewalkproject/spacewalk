-- created by Oraschemadoc Fri Mar  2 05:58:12 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_EVR" (e_in in varchar2, v_in in varchar2, r_in in varchar2)
return number
is
    evr_id  number;
begin
    select id
      into evr_id
      from rhnPackageEVR
    where ((epoch is null and e_in is null) or (epoch = e_in)) and
          version = v_in and
          release = r_in;

    return evr_id;
exception when no_data_found then
    begin
        evr_id := insert_evr(e_in, v_in, r_in);
    exception when dup_val_on_index then
        select id
          into evr_id
          from rhnPackageEVR
        where ((epoch is null and e_in is null) or (epoch = e_in)) and
              version = v_in and
              release = r_in;
    end;

	return evr_id;
end;
 
/
