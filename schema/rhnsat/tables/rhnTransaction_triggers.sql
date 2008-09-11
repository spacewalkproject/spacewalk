-- $Id$
--
-- triggers for rhnTransaction

create or replace trigger
rhn_trans_mod_trig
before insert or update on rhnTransaction
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.1  2002/09/25 19:09:02  pjones
-- transaction changes discussed today
--
