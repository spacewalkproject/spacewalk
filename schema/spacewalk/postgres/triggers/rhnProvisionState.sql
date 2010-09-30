-- oracle equivalent source sha1 98f0ebe9867779e697d17f3ae13ce59f720aa03a
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnProvisionState.sql
create or replace function rhn_provstate_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_provstate_mod_trig
before insert or update on rhnProvisionState
for each row
execute procedure rhn_provstate_mod_trig_fun();
