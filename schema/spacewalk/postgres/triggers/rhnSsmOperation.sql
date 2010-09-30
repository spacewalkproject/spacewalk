-- oracle equivalent source sha1 1a22bb238b1ecbcfc709456ca3979f18e8661f35
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSsmOperation.sql
create or replace function rhn_ssmop_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_ssmop_mod_trig
before insert or update on rhnSsmOperation
for each row
execute procedure rhn_ssmop_mod_trig_fun();


