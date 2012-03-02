-- oracle equivalent source sha1 237d19de51b9cc5bc7fa78526af4ed0d205d61ce
create or replace function rhn_cmeth_val_trig_fun() returns trigger as
$$
begin
    if new.method_type_id = 1 then

    --- pager fields pager_email,pager_split_long_messages should be not null
        if (new.pager_email   is null     or new.pager_split_long_messages  is null ) then
            raise exception 'missing or invalid data for contact_methods table'; --missing_data;
        end if;
    end if;

    if new.method_type_id = 2 then

    --- the all email fields but email_reply_to should be not null
        if new.email_address is null then
            raise exception 'missing or invalid data for contact_methods table';  --missing_data;
        end if;
    end if;

    return new;
end;
$$ language plpgsql;


create trigger
rhn_cmeth_val_trig
before insert or update on rhn_contact_methods
for each row
execute procedure rhn_cmeth_val_trig_fun();



