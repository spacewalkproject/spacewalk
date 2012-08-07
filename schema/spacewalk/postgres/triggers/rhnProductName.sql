-- oracle equivalent source sha1 330361eef5d5c8b2d0f12337bc5d38d128c73281


create or replace function product_name_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
product_name_mod_trig
before insert or update on rhnProductName
for each row
execute procedure product_name_mod_trig_fun();


