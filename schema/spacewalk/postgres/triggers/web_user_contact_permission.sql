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


