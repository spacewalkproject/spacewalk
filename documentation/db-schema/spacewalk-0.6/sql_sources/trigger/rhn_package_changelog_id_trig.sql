-- created by Oraschemadoc Mon Aug 31 10:54:38 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_PACKAGE_CHANGELOG_ID_TRIG" 
before insert on rhnPackageChangelog
for each row
 WHEN (new.id is null) begin
        select rhn_pkg_cl_id_seq.nextval into :new.id from dual;
end;
ALTER TRIGGER "MIM1"."RHN_PACKAGE_CHANGELOG_ID_TRIG" ENABLE
 
/
