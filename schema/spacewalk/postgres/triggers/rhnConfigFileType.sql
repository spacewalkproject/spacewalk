-- oracle equivalent source sha1 9d9ff77590d40a1a4336fb49425f3f8804ff7e85

create or replace function rhn_conffiletype_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_conffiletype_mod_trig
before insert or update on rhnConfigFileType
for each row
execute procedure rhn_conffiletype_mod_trig_fun();
