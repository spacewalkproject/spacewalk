--
-- $Id$
--
-- data for rhnActionStatus

insert into rhnActionStatus values (0, 'Queued', sysdate, sysdate);
insert into rhnActionStatus values (1, 'Picked Up', sysdate, sysdate);
insert into rhnActionStatus values (2, 'Completed', sysdate, sysdate);
insert into rhnActionStatus values (3, 'Failed', sysdate, sysdate);

commit;

-- $Log$
-- Revision 1.1  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
