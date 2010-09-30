-- oracle equivalent source sha1 7bca5e7b7625b73ca83a0ef5b3c87f9a6412b156
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnRepoRegenQueue.sql

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


