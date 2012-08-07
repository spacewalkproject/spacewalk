-- oracle equivalent source sha1 f673fbf2b43479d83cac99278879580d29318869

create or replace function rhn_server_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_server_mod_trig
before insert or update on rhnServer
for each row
execute procedure rhn_server_mod_trig_fun();

