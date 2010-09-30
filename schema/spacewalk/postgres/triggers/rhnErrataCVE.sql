-- oracle equivalent source sha1 da11fc61282da4aba4dc137311521183d568cac3
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnErrataCVE.sql
create or replace function rhn_errata_cve_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_errata_cve_mod_trig
before insert or update on rhnErrataCVE
for each row
execute procedure rhn_errata_cve_mod_trig_fun();
