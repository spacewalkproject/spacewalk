-- oracle equivalent source sha1 6ca5b20c385067b7b15c82812ee9912dfc3a9221

create or replace function rhn_avresume_mod_trig_fun()  returns trigger as
$$
begin
        new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_avresume_mod_trig
before insert or update on rhnActionVirtResume
for each row
execute procedure rhn_avresume_mod_trig_fun();

