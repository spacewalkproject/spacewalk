-- oracle equivalent source sha1 d5a6aa7e106c7df33dca153509dcbbe0f71d0ef9
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerActionVerifyResult.sql
create or replace function rhn_sactionvr_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_sactionvr_mod_trig
before insert or update on rhnServerActionVerifyResult
for each row
execute procedure rhn_sactionvr_mod_trig_fun();
