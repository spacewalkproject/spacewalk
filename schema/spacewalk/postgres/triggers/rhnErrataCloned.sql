-- oracle equivalent source sha1 fc8644cc659239ccdcd5b7aa5acc1abf7acfbc13
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnErrataCloned.sql
create or replace function rhn_errataclone_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_errataclone_mod_trig
before insert or update on rhnErrataCloned
for each row
execute procedure rhn_errataclone_mod_trig_fun();

