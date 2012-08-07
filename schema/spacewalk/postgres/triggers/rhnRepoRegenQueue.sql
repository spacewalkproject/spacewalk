-- oracle equivalent source sha1 9c1126cd60c336e4ddf49ce50443a803393907a5

create or replace function rhn_repo_regen_queue_mod_trig_fun() returns trigger as
$$
begin
	if new.id is null then
		new.id := nextval('rhn_repo_regen_queue_id_seq');
	end if;

	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_repo_regen_queue_mod_trig
before insert or update on rhnRepoRegenQueue
for each row
execute procedure rhn_repo_regen_queue_mod_trig_fun();


