-- oracle equivalent source sha1 6b450906e410d527fcf085a56f3137507215bc04
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerChannelArchCompat.sql
create or replace function rhn_sc_ac_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_sc_ac_mod_trig
before insert or update on rhnServerChannelArchCompat
for each row
execute procedure rhn_sc_ac_mod_trig_fun();

