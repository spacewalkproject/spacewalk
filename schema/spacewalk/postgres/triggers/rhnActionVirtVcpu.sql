-- oracle equivalent source sha1 e0427ec22d4cd4d53d57f68e70bcb69c7c44dffb

create or replace function rhn_avcpu_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_avcpu_mod_trig
before insert or update on rhnActionVirtVcpu
for each row
execute procedure rhn_avcpu_mod_trig_fun();
