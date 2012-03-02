-- created by Oraschemadoc Fri Mar  2 05:58:04 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."TIME_SERIES" ("O_ID", "ENTRY_TIME", "DATA") AS 
  (
    select tsd.org_id || '-' || tsd.probe_id || '-' || tsd.probe_desc as o_id,
           tsd.entry_time as entry_time,
           tsd.data as data
      from time_series_data tsd
    )
 
/
