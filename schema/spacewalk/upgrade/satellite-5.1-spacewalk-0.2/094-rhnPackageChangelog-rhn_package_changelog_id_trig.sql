
create or replace trigger
rhn_package_changelog_id_trig
before insert on rhnPackageChangelog
for each row
when (new.id is null)
begin
        select rhn_pkg_cl_id_seq.nextval into :new.id from dual;
end;
/ 
show errors 
 
