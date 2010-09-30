-- oracle equivalent source sha1 5f58f823d4cb0c4b0ddbd138e020ddaa1c4ec1ab
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerPreserveFileList.sql
create or replace function rhn_serverpfl_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_serverpfl_mod_trig
before insert or update on rhnServerPreserveFileList
for each row
execute procedure rhn_serverpfl_mod_trig_fun();


