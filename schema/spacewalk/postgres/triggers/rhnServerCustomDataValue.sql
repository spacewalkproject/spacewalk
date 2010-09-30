-- oracle equivalent source sha1 91ffdddaa3f7bf87411352cf5c1ea08bff85afd1
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerCustomDataValue.sql
create or replace function rhn_scdv_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_scdv_mod_trig
before insert or update on rhnServerCustomDataValue
for each row
execute procedure rhn_scdv_mod_trig_fun();

