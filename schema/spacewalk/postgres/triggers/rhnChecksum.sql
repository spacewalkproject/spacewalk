-- oracle equivalent source sha1 16ba4eab193f0d76825a377688db70911775fb1b

create or replace function rhn_checksum_mod_trig_fun() returns trigger as
$$
begin
	if new.id is null then
		new.id := nextval('rhn_checksum_seq_id_seq');
	end if;

	return new;
end;
$$ language plpgsql;

create trigger
rhn_checksum_queue_mod_trig
before insert or update on rhnChecksum
for each row
execute procedure rhn_checksum_mod_trig_fun();
