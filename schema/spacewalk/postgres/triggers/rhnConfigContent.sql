-- oracle equivalent source sha1 0111c7616895e158d6f045a1af92b00093f5ab05

create or replace function rhn_confcontent_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_confcontent_mod_trig
before insert or update on rhnConfigContent
for each row
execute procedure rhn_confcontent_mod_trig_fun();
