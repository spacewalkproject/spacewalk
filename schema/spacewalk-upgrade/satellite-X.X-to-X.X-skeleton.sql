SET ECHO ON;
whenever sqlerror exit;

spool satellite-X.X-to-X.X.log;

variable evr_id number;
variable epoch varchar2(16);
variable version varchar2(64);
variable release varchar2(64);

variable message varchar2(80);

declare
   cursor evrs is
      select   e.id, e.epoch, e.version, e.release, e.evr
      from  rhnPackageEVR e,
         rhnVersionInfo rvi
      where rvi.label = 'schema'
         and rvi.name_id =
            lookup_package_name('rhn-satellite-schema')
         and rvi.evr_id = e.id;
   cursor valid_evrs is
      select   1
      from  dual
      where :evr_id in (
         lookup_evr('','X.X','YYY')
         );
begin
   :evr_id := null;
   :message := 'XXX Invalid satellite schema version.';
   for evr in evrs loop
      :evr_id := evr.id;
      :epoch := evr.epoch;
      :version := evr.version;
      :release := evr.release;
      :message :=  '*** Schema version is currently ' ||
         evr.evr.as_vre_simple() ||
         ', and will NOT be upgraded';
      for vevr in valid_evrs loop
         :message :=  '*** Schema version is currently ' ||
            evr.evr.as_vre_simple() ||
            ', and will be upgraded';
      end loop;
      return;
   end loop;
end;
/
show errors;


select :message from dual;

declare
   invalid_schema_version exception;
   cursor valid_evrs is
      select   1
      from  dual
      where :evr_id in (
         lookup_evr('','X.X','YYY')
         );
begin
   for vevr in valid_evrs loop
      return;
   end loop;
   raise invalid_schema_version;
end;
/
show errors;

set define off;

-- Upgrade body
-- Upgrade body
-- Upgrade body
-- Upgrade body
-- Upgrade body

update rhnVersionInfo set evr_id = lookup_evr(null, 'X.X', 'YYY')
   where label = 'schema'
   and name_id = lookup_package_name('rhn-satellite-schema');

select   '*** Schema version is now ' || e.evr.as_vre_simple()
from  rhnPackageEVR e, rhnVersionInfo vi
where vi.evr_id = e.id
  and   vi.label = 'schema';

commit;


spool off;
exit;
