-- oracle equivalent source sha1 65343f2baf34323725bb91e9e45170ab4efe9989

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


