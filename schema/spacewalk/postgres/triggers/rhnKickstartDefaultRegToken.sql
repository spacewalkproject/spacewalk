-- oracle equivalent source sha1 87bb25c891d780970f87d1b5c8f24e5ee1299eb9

create or replace function rhn_ksdrt_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ksdrt_mod_trig
before insert or update on rhnKickstartDefaultRegToken
for each row
execute procedure rhn_ksdrt_mod_trig_fun();

