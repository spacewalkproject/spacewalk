--
-- $Id$
--
-- update timestamp

create or replace trigger
web_customer_mod_trig
before insert or update on web_customer
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

