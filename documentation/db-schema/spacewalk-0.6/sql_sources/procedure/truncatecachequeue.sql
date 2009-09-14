-- created by Oraschemadoc Mon Aug 31 10:54:41 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "MIM1"."TRUNCATECACHEQUEUE" as
begin
  execute immediate 'Truncate Table rhnOrgErrataCacheQueue';
end;
 
/
