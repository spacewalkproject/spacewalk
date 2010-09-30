-- oracle equivalent source sha1 65f9a4b13498de76382b404c4215f40059d23f23
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnConfigFileFailure.sql
create or replace function rhn_conffile_fail_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_conffile_fail_mod_trig
before insert or update on rhnConfigFileFailure
for each row
execute procedure rhn_conffile_fail_mod_trig_fun();

