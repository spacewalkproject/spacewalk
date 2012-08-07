-- oracle equivalent source sha1 27d17afb05af5837ff607017ddf04549a2205c82

create or replace function rhn_ks_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ks_mod_trig
before insert or update on rhnKSData
for each row
execute procedure rhn_ks_mod_trig_fun();

