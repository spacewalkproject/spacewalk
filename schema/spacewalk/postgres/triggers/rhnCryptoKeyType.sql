-- oracle equivalent source sha1 f8ac1427ac0a600c3ea1be0e227b8243a8ff5aa3
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnCryptoKeyType.sql
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

