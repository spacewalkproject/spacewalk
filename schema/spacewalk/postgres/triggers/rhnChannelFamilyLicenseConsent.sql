create or replace function rhn_cfl_consent_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_cfl_consent_mod_trig
before insert or update on rhnChannelFamilyLicenseConsent
for each row
execute procedure rhn_cfl_consent_mod_trig_fun();
