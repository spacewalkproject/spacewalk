create or replace function rhn_kstree_mod_trig_fun() returns trigger as
$$
begin
        if (new.last_modified = old.last_modified) or        
        (new.last_modified is null ) then
             new.last_modified := sysdate;
	end if;

        new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_kstree_mod_trig
before insert or update on rhnKickstartableTree
for each row
execute procedure rhn_kstree_mod_trig_fun();

