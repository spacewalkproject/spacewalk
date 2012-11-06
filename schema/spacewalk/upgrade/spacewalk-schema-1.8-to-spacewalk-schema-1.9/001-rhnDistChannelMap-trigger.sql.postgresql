-- oracle equivalent source sha1 b04dab2ff31049a8744e5ce1531ccd8b00152bbc

create or replace function rhn_dist_channel_map_mod_trig_fun() returns trigger as
$$
begin
    if new.id is null then
        new.id := nextval('rhn_dcm_id_seq');
    end if;
    return new;
end;
$$ language plpgsql;

