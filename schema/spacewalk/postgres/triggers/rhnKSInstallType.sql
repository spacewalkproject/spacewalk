-- oracle equivalent source sha1 53fecbad84385e34dde2ed5025c0d13a1da64f85

create or replace function rhn_ksinstalltype_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ksinstalltype_mod_trig
before insert or update on rhnKSInstallType
for each row
execute procedure rhn_ksinstalltype_mod_trig_fun();

