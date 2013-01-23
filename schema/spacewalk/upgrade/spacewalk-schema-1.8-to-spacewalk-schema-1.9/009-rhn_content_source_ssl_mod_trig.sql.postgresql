-- oracle equivalent source sha1 69c5d82c00ea96836eed1be6a65507f53b7730f3

create or replace function rhn_cont_source_ssl_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;


create trigger
rhn_cont_source_ssl_mod_trig
before insert or update on rhnContentSourceSsl
for each row
execute procedure rhn_cont_source_ssl_mod_trig_fun();
