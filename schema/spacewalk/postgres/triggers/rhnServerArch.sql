-- oracle equivalent source sha1 37ea15dfa04577c8b99fda538d2d153f99df95ab
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnServerArch.sql
create or replace function rhn_sarch_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_sarch_mod_trig
before insert or update on rhnServerArch
for each row
execute procedure rhn_sarch_mod_trig_fun();

