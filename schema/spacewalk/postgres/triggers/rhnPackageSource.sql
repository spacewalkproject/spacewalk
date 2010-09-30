-- oracle equivalent source sha1 e1a806990bd4041f55f197f0d0cac1239ef7deb0
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageSource.sql
create or replace function rhn_pkgsrc_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	new.last_modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkgsrc_mod_trig
before insert or update on rhnPackageSource
for each row
execute procedure rhn_pkgsrc_mod_trig_fun();

