-- oracle equivalent source sha1 9186ddb8d4b222ae28504a4cffa7f2ea22e06ad1
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnKickstartPreserveFileList.sql
create or replace function rhn_kspreservefl_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_kspreservefl_mod_trig
before insert or update on rhnKickstartPreserveFileList
for each row
execute procedure rhn_kspreservefl_mod_trig_fun();

