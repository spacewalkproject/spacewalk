-- oracle equivalent source sha1 f9def13f57a133f57c313fa2c564c5ba00ae7f22
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnProduct.sql
create or replace function rhn_product_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	new.last_modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_product_mod_trig
before insert or update on rhnProduct
for each row
execute procedure rhn_product_mod_trig_fun();

