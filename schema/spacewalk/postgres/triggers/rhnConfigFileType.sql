-- oracle equivalent source sha1 885cb40eeda98dd09649016105731adae2dbcc34

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
