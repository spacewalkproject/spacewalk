-- created by Oraschemadoc Fri Mar  2 05:58:12 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_SNAPSHOT_INVALID_REASON" (label_in in varchar2)
return number
is
	snapshot_invalid_reason_id number;
begin
    select id
      into snapshot_invalid_reason_id
      from rhnsnapshotinvalidreason
     where label = label_in;

    return snapshot_invalid_reason_id;
exception when no_data_found then
    rhn_exception.raise_exception('invalid_snapshot_invalid_reason');
end;
 
/
