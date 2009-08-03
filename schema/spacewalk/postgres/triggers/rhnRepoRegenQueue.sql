
create or replace function rhn_repo_regen_queue_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_repo_regen_queue_mod_trig
before insert or update on rhnRepoRegenQueue
for each row
execute procedure rhn_repo_regen_queue_mod_trig_fun();


