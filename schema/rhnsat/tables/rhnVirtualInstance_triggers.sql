--
-- $Id: $
--

create or replace trigger
rhn_virtinst_mod_trig
before insert or update on rhnVirtualInstance
for each row
begin
        :new.modified := sysdate;
end;
/
show errors;

