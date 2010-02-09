-- created by Oraschemadoc Fri Jan 22 13:39:23 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE GLOBAL TEMPORARY TABLE "SPACEWALK"."RHNPAIDERRATATEMPCACHE"
   (	"ERRATA_ID" NUMBER, 
	"USER_ID" NUMBER, 
	"SERVER_ID" NUMBER
   ) ON COMMIT DELETE ROWS 
 
/
