-- oracle equivalent source sha1 ff2fbf8d1a07cc723a922108612eb0b7ed184c8a
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnTag.sql
create or replace function rhn_tag_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_tag_mod_trig
before insert or update on rhnTag
for each row
execute procedure rhn_tag_mod_trig_fun();


