-- oracle equivalent source sha1 07d0dd554e4db74ef60e2f92fb51484503da348c
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerActionPackageResult.sql
create or replace function rhn_sap_result_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_sap_result_mod_trig
before insert or update on rhnServerActionPackageResult
for each row
execute procedure rhn_sap_result_mod_trig_fun();

