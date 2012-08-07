-- oracle equivalent source sha1 6e1e553525cd6604c5e5cde45fb329640ee2c312

create or replace function rhn_kspreservefl_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_kspreservefl_mod_trig
before insert or update on rhnKickstartPreserveFileList
for each row
execute procedure rhn_kspreservefl_mod_trig_fun();

