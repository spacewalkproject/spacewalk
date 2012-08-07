-- oracle equivalent source sha1 36dce2ddc0930a597cd17bf76868792e94163a1b

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
