-- oracle equivalent source sha1 493ffc63c558ac75b7466d2bcb49b8fa0055fa69
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSolarisPatchSetMembers.sql
create or replace function rhn_solaris_psm_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_solaris_psm_mod_trig
before insert or update on rhnSolarisPatchSetMembers
for each row
execute procedure rhn_solaris_psm_mod_trig_fun();


