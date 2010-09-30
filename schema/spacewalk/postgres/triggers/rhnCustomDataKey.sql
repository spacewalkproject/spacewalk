-- oracle equivalent source sha1 1ea204806315db2553c0d13f26a28f46e862e314
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnCustomDataKey.sql

create or replace function rhn_cdatakey_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_cdatakey_mod_trig
before insert or update on rhnCustomDataKey
for each row
execute procedure rhn_cdatakey_mod_trig_fun();

