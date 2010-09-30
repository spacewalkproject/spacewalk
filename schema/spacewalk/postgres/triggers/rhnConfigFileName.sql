-- oracle equivalent source sha1 3c18cf3277767937bc7597957070f395cd28ee46
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnConfigFileName.sql
create or replace function rhn_cfname_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_cfname_mod_trig
before insert or update on rhnConfigFileName
for each row
execute procedure rhn_cfname_mod_trig_fun();

