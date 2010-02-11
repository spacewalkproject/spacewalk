-- created by Oraschemadoc Fri Jan 22 13:40:59 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_PACKAGE_CHANGELOG_ID_TRIG"
before insert on rhnPackageChangelog
for each row
 WHEN (new.id is null) begin
        select rhn_pkg_cl_id_seq.nextval into :new.id from dual;
end;
ALTER TRIGGER "SPACEWALK"."RHN_PACKAGE_CHANGELOG_ID_TRIG" ENABLE
 
/
