-- oracle equivalent source sha1 3caf6c37aad78b3f7aa919ae8fd4895a0e187c14

create or replace function rhn_channel_errata_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_channel_errata_mod_trig
before insert or update on rhnChannelErrata
for each row
execute procedure rhn_channel_errata_mod_trig_fun();
