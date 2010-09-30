-- oracle equivalent source sha1 1210a1b4e2eaaa964f5017255bce52c04f0c16d4
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnProductName.sql

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


