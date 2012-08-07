-- oracle equivalent source sha1 428fe40b79e92a0f9dda9f40ab26a738b00a5af6


create or replace function web_user_si_timestamp_fun() returns trigger as
$$
begin
	
	new.email_uc := upper(new.email);
	new.modified := current_timestamp;

 	return new;
end;
$$ language plpgsql;

create trigger
web_user_si_timestamp
before insert or update on web_user_site_info
for each row
execute procedure web_user_si_timestamp_fun();


