-- created by Oraschemadoc Fri Mar  2 05:58:08 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_PROBE_INSERT_TRIGGER" after insert on rhn_probe
for each row
begin
    insert into time_series_purge (id, probe_id, deleted) values (:new.recid, :new.recid, 0);
end;
ALTER TRIGGER "SPACEWALK"."RHN_PROBE_INSERT_TRIGGER" ENABLE
 
/
