-- oracle equivalent source sha1 aaf3c8e2ed94d98005edbd5d22f0d7c4834edf28
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnDownloads.sql
create or replace function rhn_download_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_download_mod_trig
before insert or update on rhnDownloads
for each row
execute procedure rhn_download_mod_trig_fun();

