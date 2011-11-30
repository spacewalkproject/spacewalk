-- oracle equivalent source sha1 1ea0fa0493bd58e3cff2b3a8f6294710e77f4d0b
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

drop trigger if exists rhn_srv_net_iface_mod_trig on rhnServerNetInterface;

create trigger
rhn_srv_net_iface_mod_trig
before insert or update on rhnServerNetInterface
for each row
execute procedure rhn_srv_net_iface_mod_trig_fun();
