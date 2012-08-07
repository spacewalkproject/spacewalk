-- oracle equivalent source sha1 d6304c6be387148e6bfe20471343ef3e78e58a91

create or replace function rhn_efilec_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_efilec_mod_trig
before insert or update on rhnErrataFileChannel
for each row
execute procedure rhn_efilec_mod_trig_fun();
