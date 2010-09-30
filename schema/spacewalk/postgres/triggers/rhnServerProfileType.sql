-- oracle equivalent source sha1 bee0e4a42b21e6ffca1d26bf2a119867fd6615bd
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerProfileType.sql

create or replace function rhn_sproftype_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_sproftype_mod_trig
before insert or update on rhnServerProfileType
for each row
execute procedure rhn_sproftype_mod_trig_fun();


