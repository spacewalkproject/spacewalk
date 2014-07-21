-- oracle equivalent source sha1 52fb74d626c2a728437edbd2f95ac11be15dfba0

create or replace function rhn_kstree_mod_trig_fun() returns trigger as
$$
begin
        if tg_op='UPDATE' then
                -- Basically if we're changing something other than cobbler_id,
                -- cobbler_xen_id, and last_modified - or if last_modified is
                -- explicity set to null. Gets complicated because we have
                -- to allow for the possibility of the ids being null
                if ((not old.cobbler_id is null and new.cobbler_id = old.cobbler_id)
                        or (old.cobbler_id is null and new.cobbler_id is null))
                    and ((not old.cobbler_xen_id is null and new.cobbler_xen_id = old.cobbler_xen_id)
                        or (old.cobbler_xen_id is null and new.cobbler_xen_id is null))
                    and new.last_modified = old.last_modified
                    or new.last_modified is null
                then
                    new.last_modified := current_timestamp;
                end if;
        elseif tg_op='INSERT' and new.last_modified is null then
                new.last_modified := current_timestamp;
        end if;

        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;
