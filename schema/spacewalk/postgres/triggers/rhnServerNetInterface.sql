-- oracle equivalent source sha1 e70841a1bf2069970b4742ee1cd2e67591ce5d9b
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

