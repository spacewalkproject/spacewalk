-- oracle equivalent source sha1 1a3a430ef6963b67adb8ac9253d251be8b794f76
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/web_user_contact_permission.sql
create or replace function web_user_cp_timestamp_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;

 	return new;
end;
$$ language plpgsql;

create trigger
web_user_cp_timestamp
before insert or update on web_user_contact_permission
for each row
execute procedure web_user_cp_timestamp_fun();


