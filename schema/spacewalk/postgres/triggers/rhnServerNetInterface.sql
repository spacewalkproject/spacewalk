-- oracle equivalent source sha1 d37db54a176f593bd9727921ed20d00d6cd95f4b
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerNetInterface.sql
create or replace function rhn_srv_net_iface_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_srv_net_iface_mod_trig
before insert or update on rhnServerNetInterface
for each row
execute procedure rhn_srv_net_iface_mod_trig_fun();

