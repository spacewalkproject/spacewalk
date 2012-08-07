-- oracle equivalent source sha1 b4fc98df9eb81f7c8509c838555326a32cc3933f

create or replace function rhn_efilectmp_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_efilectmp_mod_trig
before insert or update on rhnErrataFileChannelTmp
for each row
execute procedure rhn_efilectmp_mod_trig_fun();
