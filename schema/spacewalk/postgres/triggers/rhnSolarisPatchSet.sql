-- oracle equivalent source sha1 0513f9a5de57c6f5387bd9aa7997630255dbe905
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSolarisPatchSet.sql
create or replace function rhn_solaris_ps_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_solaris_ps_mod_trig
before insert or update on rhnSolarisPatchSet
for each row
execute procedure rhn_solaris_ps_mod_trig_fun();


