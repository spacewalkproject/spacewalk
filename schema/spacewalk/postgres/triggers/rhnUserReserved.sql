-- oracle equivalent source sha1 07959ae19aca0c2d993b4764dd49463db2ff503b
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnUserReserved.sql
create or replace function rhn_user_res_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_user_res_mod_trig
before insert or update on rhnUserreserved
for each row
execute procedure rhn_user_res_mod_trig_fun();


