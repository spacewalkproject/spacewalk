-- oracle equivalent source sha1 2330953d139fc07f77743e6bc63abb49d0a2d147

create or replace function rhn_content_source_ssl_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;


create trigger
rhn_content_source_ssl_mod_trig
before insert or update on rhnContentSourceSsl
for each row
execute procedure rhn_content_source_ssl_mod_trig_fun();
