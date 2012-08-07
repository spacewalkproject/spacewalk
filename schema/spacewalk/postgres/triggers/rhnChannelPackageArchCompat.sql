-- oracle equivalent source sha1 9da15450a03a857e4fe15862e463bd850f7e18bb

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
