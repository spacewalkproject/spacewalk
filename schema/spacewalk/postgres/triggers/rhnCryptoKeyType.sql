-- oracle equivalent source sha1 47831c8d26ccad929699339f6122cffcbb77e52d

create or replace function rhn_cryptokeytype_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_cryptokeytype_mod_trig
before insert or update on rhnCryptoKeyType
for each row
execute procedure rhn_cryptokeytype_mod_trig_fun();

