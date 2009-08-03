create or replace function rhn_errataclone_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_errataclone_mod_trig
before insert or update on rhnErrataCloned
for each row
execute procedure rhn_errataclone_mod_trig_fun();

