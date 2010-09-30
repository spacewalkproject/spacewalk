-- oracle equivalent source sha1 18d13575913f81b6649cd9c8bc687b0b3cbcb2de
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageKey.sql


create or replace function rhn_pkg_gpg_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_gpg_mod_trig
before insert or update on rhnPackageKey
for each row
execute procedure rhn_pkg_gpg_mod_trig_fun();

