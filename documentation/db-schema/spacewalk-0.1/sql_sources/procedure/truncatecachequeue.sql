-- created by Oraschemadoc Fri Jun 13 14:06:11 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "RHNSAT"."TRUNCATECACHEQUEUE" as
curnum number;
begin
curnum  := dbms_sql.open_cursor;
dbms_sql.parse(curnum, 'Truncate Table rhnOrgErrataCacheQueue', dbms_sql.v7);
dbms_sql.close_cursor(curnum);
end;
 
/
