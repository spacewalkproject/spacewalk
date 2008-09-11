-- $Id$
--
-- triggers for rhnTransactionOperation

create or replace trigger
rhn_transop_mod_trig
before insert or update on rhnTransactionOperation
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
