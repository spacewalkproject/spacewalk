-- oracle equivalent source sha1 fa3137ec2a00ab880a70710107528e7aa3499a40

create or replace function rhn_confchantype_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_confchantype_mod_trig
before insert or update on rhnConfigChannelType
for each row
execute procedure rhn_confchantype_mod_trig_fun();

