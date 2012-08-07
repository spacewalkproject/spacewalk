-- oracle equivalent source sha1 ea137214270003a152d6760ab99f8e3f93fc94a1
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

