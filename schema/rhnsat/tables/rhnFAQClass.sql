--
-- $Id$
--
-- classes of FAQ questions

create table
rhnFAQClass
(
	id	    number
		    constraint rhn_faq_class_id_nn not null
		    constraint rhn_faq_class_id_pk primary key
			using index tablespace [[64k_tbs]]
			storage(pctincrease 1),
	name	    varchar2(128),
	label       varchar2(32)
	    	    constraint rhn_faq_class_label_nn not null,
	ordering  number
	            constraint rhn_faq_class_or_nn not null
)
	storage ( freelists 16 )
	initrans 32;

CREATE SEQUENCE RHN_FAQ_CLASS_ID_SEQ START WITH 101;

create unique index rhn_faqclass_label_uq
	on rhnFAQClass(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
create unique index rhn_faqclass_or_uq
	on rhnFAQClass(ordering)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.7  2003/05/19 21:56:22  cturner
-- hardcode IDs into script and start the sequence higher; necessary for proper schema exports of FAQ data.  unfortunate.
--
-- Revision 1.6  2003/04/07 14:14:29  pjones
-- bugzilla: none
--
-- We want FAQ in satellite now.
--
-- Revision 1.5  2003/03/26 16:46:14  cturner
-- yay, we are now in qa
--
-- Revision 1.4  2003/03/17 16:25:20  rnorwood
-- bugzilla: 85612 - bugfixes for FAQ class schema.
--
-- Revision 1.3  2003/03/17 16:11:52  rnorwood
-- bugzilla: 85612 - first pass of FAQ classes.
--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/05/10 21:54:45  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
--
