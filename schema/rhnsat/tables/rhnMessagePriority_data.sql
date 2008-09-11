--
-- $Id$
--
-- data for rhnMessagePriority

insert into rhnMessagePriority values (
	rhn_m_priority_id_seq.nextval, 'warning'
);

insert into rhnMessagePriority values (
	rhn_m_priority_id_seq.nextval, 'error'
);



-- $Log$
-- Revision 1.3  2002/08/12 16:35:50  bretm
-- o  heh, need this one too.
--
-- Revision 1.2  2002/08/12 16:31:40  bretm
-- o  for now, dagg is looking for warnings or errors...
--
-- Revision 1.1  2002/07/29 20:26:23  pjones
-- add support for labeled message priorities
--
