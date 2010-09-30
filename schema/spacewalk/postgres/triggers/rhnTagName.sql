-- oracle equivalent source sha1 89e44ddb120ade475bac3cba05f09b49414d71d6
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnTagName.sql
create or replace function rhn_tn_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_tn_mod_trig
before insert or update on rhnTagName
for each row
execute procedure rhn_tn_mod_trig_fun();


