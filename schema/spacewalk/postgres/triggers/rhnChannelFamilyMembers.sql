-- oracle equivalent source sha1 d0558e7438c01d2e4bba1a8a00f37bdf4898763e
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnChannelFamilyMembers.sql

create or replace function rhn_cf_member_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_cf_member_mod_trig
before insert or update on rhnChannelFamilyMembers
for each row
execute procedure rhn_cf_member_mod_trig_fun();
