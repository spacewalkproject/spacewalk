-- oracle equivalent source sha1 dad3fd270a0d44713bb4d0f05b748171f225ba64
-- retrieved from ./1241132947/9984c41fb98d15becf3c29432c19cd7a266dece4/schema/spacewalk/oracle/triggers/rhnKickstartableTree.sql
create or replace function rhn_kstree_mod_trig_fun() returns trigger as
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
rhn_kstree_mod_trig
before insert or update on rhnKickstartableTree
for each row
execute procedure rhn_kstree_mod_trig_fun();

