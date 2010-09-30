-- oracle equivalent source sha1 49a22b8f44842ae2f6b1474773a961bd6cb8f3dd
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerActionVerifyMissing.sql
create or replace function rhn_sactionvm_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_sactionvm_mod_trig
before insert or update on rhnServerActionVerifyMissing
for each row
execute procedure rhn_sactionvm_mod_trig_fun();

