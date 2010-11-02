-- created by Oraschemadoc Tue Nov  2 08:33:18 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."DATE_DIFF_IN_DAYS" (ts1 in date, ts2 in date)
return number is
begin
    return ts2 - ts1;
end date_diff_in_days;
 
/
