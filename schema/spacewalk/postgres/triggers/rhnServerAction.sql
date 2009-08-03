create or replace function rhn_server_action_mod_trig_fun() returns trigger as
$$
declare
        handle_status   numeric;
begin
        new.modified := current_timestamp;
        handle_status := 0;
        if TG_OP = 'UPDATE' then
                if new.status is distinct from old.status then
                        handle_status := 1;
                end if;
        else
                handle_status := 1;
        end if;

        if handle_status = 1 then
                if new.status = 1 then
                        new.pickup_time := current_timestamp;
                elsif new.status = 2 then
                        new.completion_time := current_timestamp;
                end if;
        end if;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_server_action_mod_trig
before insert or update on rhnServerAction
for each row
execute procedure rhn_server_action_mod_trig_fun();

