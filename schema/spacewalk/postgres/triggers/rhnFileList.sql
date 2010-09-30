-- oracle equivalent source sha1 08c036452858014d316b8935db873ec4f1c8adba
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnFileList.sql
create or replace function rhn_filelist_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_filelist_mod_trig
before insert or update on rhnFileList
for each row
execute procedure rhn_filelist_mod_trig_fun();
