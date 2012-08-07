-- oracle equivalent source sha1 f082ac0a2e9181f759e8c8d6f4c595c0c4e65c9e

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

