-- oracle equivalent source sha1 d8f74a12a9e438ed79df6a5c436f2b9957d928d6
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnConfigContent.sql
create or replace function rhn_confcontent_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_confcontent_mod_trig
before insert or update on rhnConfigContent
for each row
execute procedure rhn_confcontent_mod_trig_fun();
