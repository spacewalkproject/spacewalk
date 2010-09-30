-- oracle equivalent source sha1 2dd1af534b1a28a155096efacbe9cd4c799b51e9
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnChannelPackageArchCompat.sql
create or replace function rhn_cp_ac_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_cp_ac_mod_trig
before insert or update on rhnChannelPackageArchCompat
for each row
execute procedure rhn_cp_ac_mod_trig_fun();
