-- oracle equivalent source sha1 3524cbfc189420e5300d30b682c8fcfc5546465d

create or replace function rhn_channel_family_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_channel_family_mod_trig
before insert or update on rhnChannelFamily
for each row
execute procedure rhn_channel_family_mod_trig_fun();
