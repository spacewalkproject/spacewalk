-- oracle equivalent source sha1 ef4142dd5c460a2445f9360a66f4cddeb99238f5
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/web_user_site_info.sql

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


