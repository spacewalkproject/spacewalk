-- oracle equivalent source sha1 5801140cbc5ef0b8f5bf6f3dcded90a9f2e54586
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnConfigChannelType.sql
create or replace function rhn_confchantype_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_confchantype_mod_trig
before insert or update on rhnConfigChannelType
for each row
execute procedure rhn_confchantype_mod_trig_fun();

