--
-- $Id$
--
-- data for rhnTransactionOperation

insert into rhnTransactionOperation (id, label) values (1,'insert');
insert into rhnTransactionOperation (id, label) values (2,'delete');
insert into rhnTransactionOperation (id, label) values (3,'upgrade');

-- $Log$
-- Revision 1.2  2003/07/02 21:33:28  pjones
-- bugzilla: none
--
-- add "upgrade" transaction type
--
-- Revision 1.1  2002/09/25 19:21:36  pjones
-- more of the transaction changes
--
