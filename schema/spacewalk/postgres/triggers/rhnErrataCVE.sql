-- oracle equivalent source sha1 10a79d5c34ad9d453aa081667469d2f104450c40

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
