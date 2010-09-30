-- oracle equivalent source sha1 73dabf90e09c7d648834aca22ea5b0ccf1330615
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnAppInstallInstance.sql
create or replace function rhn_appinst_istance_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_appinst_istance_mod_trig
before insert or update on rhnAppInstallInstance
for each row
execute procedure rhn_action_mod_trig_fun();
