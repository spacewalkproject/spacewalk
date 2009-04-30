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

