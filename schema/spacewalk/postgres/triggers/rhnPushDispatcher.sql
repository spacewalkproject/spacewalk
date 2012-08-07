-- oracle equivalent source sha1 2ff9d309b1cd9f7c23c1d94c003af0363c2c254f

create or replace function rhn_pushdispatch_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pushdispatch_mod_trig
before insert or update on rhnPushDispatcher
for each row
execute procedure rhn_pushdispatch_mod_trig_fun();

