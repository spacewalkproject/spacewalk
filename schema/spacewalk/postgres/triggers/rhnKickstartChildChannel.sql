-- oracle equivalent source sha1 cd4feb63d6d0b09309a49346e280f674c9b1224b
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnKickstartChildChannel.sql
create or replace function rhn_ks_cc_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ks_cc_mod_trig
before insert or update on rhnKickstartChildChannel
for each row
execute procedure rhn_ks_cc_mod_trig_fun();

