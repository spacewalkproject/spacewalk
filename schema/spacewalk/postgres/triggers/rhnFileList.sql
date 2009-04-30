create or replace function rhn_filelist_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_filelist_mod_trig
before insert or update on rhnFileList
for each row
execute procedure rhn_filelist_mod_trig_fun();
