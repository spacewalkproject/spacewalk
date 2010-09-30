-- oracle equivalent source sha1 38f5ad9ab7df6fec43841dfa0c3f5479e068eed9
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerMessage.sql
create or replace function rhn_sm_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_sm_mod_trig
before insert or update on rhnServerMessage
for each row
execute procedure rhn_sm_mod_trig_fun();


