-- oracle equivalent source sha1 51e0e17ac01669ffa73c1be8132c856d14ee7ec4
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnRam.sql
create or replace function rhn_ram_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_ram_mod_trig
before insert or update on rhnRam
for each row
execute procedure rhn_ram_mod_trig_fun();


