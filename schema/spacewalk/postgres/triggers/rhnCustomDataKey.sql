-- oracle equivalent source sha1 0fb3a28bcbe1cfd49adcc39588f4f44c5169417c


create or replace function rhn_cdatakey_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_cdatakey_mod_trig
before insert or update on rhnCustomDataKey
for each row
execute procedure rhn_cdatakey_mod_trig_fun();

