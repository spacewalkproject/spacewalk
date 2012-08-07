-- oracle equivalent source sha1 b0e2474408c6a02ab32e0e888483d8d13991a523

create or replace function rhn_conffile_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_conffile_mod_trig
before insert or update on rhnConfigFile
for each row
execute procedure rhn_conffile_mod_trig_fun();
