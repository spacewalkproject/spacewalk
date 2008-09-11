--
-- $Id$
--

create table
rhnSet
(
	user_id		number
			constraint rhn_set_user_nn not null
			constraint rhn_set_user_fk
				   references web_contact(id)
				   on delete cascade,
	label		varchar2(32)
			constraint rhn_set_label_nn not null,
	element		number
			constraint rhn_set_elem_nn not null,
	element_two	number,
	constraint	rhn_set_user_label_elem_unq
		UNIQUE(user_id, label, element, element_two)
		using index tablespace [[8m_tbs]]
)
	storage ( freelists 16 )
	initrans 32;

alter table rhnSet nologging;

-- $Log$
-- Revision 1.9  2003/02/18 16:08:49  pjones
-- cascades for delete_user
--
-- Revision 1.8  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.7  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
