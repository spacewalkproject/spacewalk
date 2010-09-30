-- oracle equivalent source sha1 48ea8955d39cf751f7a25f9308d2b1690c3e9c99
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerNetwork.sql
create or replace function rhn_servernetwork_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_servernetwork_mod_trig
before insert or update on rhnServerNetwork
for each row
execute procedure rhn_servernetwork_mod_trig_fun();


