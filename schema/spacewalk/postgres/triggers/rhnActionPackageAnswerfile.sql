-- oracle equivalent source sha1 ef225475df49d2e5c20e4d957a51dee6852a396b
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnActionPackageAnswerfile.sql
create or replace function rhn_act_p_af_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_act_p_af_mod_trig
before insert or update on rhnActionPackageAnswerfile
for each row
execute procedure rhn_act_p_af_mod_trig_fun();
