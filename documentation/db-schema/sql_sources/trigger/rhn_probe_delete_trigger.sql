-- created by Oraschemadoc Fri Mar  2 05:58:08 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_PROBE_DELETE_TRIGGER" before delete on rhn_probe
for each row
begin
    update time_series_purge
       set probe_id = null
     where id = :old.recid;

    update time_series_purge
       set deleted = 1
     where id = :old.recid;
end;
ALTER TRIGGER "SPACEWALK"."RHN_PROBE_DELETE_TRIGGER" ENABLE
 
/
