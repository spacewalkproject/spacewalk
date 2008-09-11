--
-- $Id$
--

create or replace trigger
rhn_action_statusmod_trig
before insert or update on rhnActionStatus
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

