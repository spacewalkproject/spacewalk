
create or replace function rhn_m_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
       return new;
end;
$$ language plpgsql;

create trigger
rhn_m_mod_trig
before insert or update on rhnMessage
for each row
execute procedure rhn_m_mod_trig_fun();

