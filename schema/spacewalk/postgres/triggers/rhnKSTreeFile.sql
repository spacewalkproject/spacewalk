-- oracle equivalent source sha1 55859618006fb64b787d5657ebf9df5288c46726
-- retrieved from ./1241132947/9984c41fb98d15becf3c29432c19cd7a266dece4/schema/spacewalk/oracle/triggers/rhnKSTreeFile.sql
create or replace function rhn_kstreefile_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        if tg_op='UPDATE' then
          if new.last_modified = old.last_modified or
             new.last_modified is null then
		new.last_modified := current_timestamp;
          end if;
        else
          if new.last_modified is null then
		new.last_modified := current_timestamp;
          end if;
        end if;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_kstreefile_mod_trig
before insert or update on rhnKSTreeFile
for each row
execute procedure rhn_kstreefile_mod_trig_fun();


