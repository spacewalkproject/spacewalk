-- oracle equivalent source sha1 1c9678fc0e82b0d0e1f659358120c971bc9bda20
create or replace function rhn_srv_net_iface_mod_trig_fun() returns trigger as
$$
begin
    if new.id is null then 
    	new.id := nextval('rhn_srv_net_iface_id_seq'); 
    end if;
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_srv_net_iface_mod_trig
before insert or update on rhnServerNetInterface
for each row
execute procedure rhn_srv_net_iface_mod_trig_fun();

