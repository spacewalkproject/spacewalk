create or replace function rhn_ks_sessionhist_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ks_sessionhist_mod_trig
before insert or update on rhnKickstartSessionHistory
for each row
execute procedure rhn_ks_sessionhist_mod_trig_fun();

